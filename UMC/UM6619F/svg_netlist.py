# SVG Netlist generator
# Cell definition SVGs in ./Cells/
# Parameter is SVG from which to generate netlist
# Layers with cells must start with "C "
# Layers with traces must start with "T "
# Cell IDs (row/column coordinates) must be unique

# Here's the idea to detect if a cell is flipped or not, and adjust netlist accordingly without doing two traces passes:
# For each cell, have a list of "missed" trace points that are in them but don't land on any pad, like (trace_id, px, py).
# Once the traces pass is done, look for cells that have none or few pads connected and a populated list of missed points.
# Try flipping the x coordinates of the pads for those cells and see if more pads become connected.
# If so, set the cell as being flipped, update the pads with the trace names, and the traces with the pad names.

from time import perf_counter_ns
from xml.dom import minidom
import os
import sys
import msgpack

cell_parse_limit = 10000
trace_parse_limit = 100000

# Label is case sensitive !
def find_layer(label):
	global doc, svgname
	found = False

	for layer in doc.getElementsByTagName('g'):
	    if layer.getAttribute("inkscape:label") == label:
	        found = True
	        break
	
	if found == False:
	    print("%s: No '%s' layer !" % (svgname, label))
	    exit()

	return layer

def find_layers_type(char):
	global doc
	found = []

	for layer in doc.getElementsByTagName('g'):
	    if layer.getAttribute("inkscape:label").split(' ')[0] == char:
	        found.append(layer)

	return found

# Desc is case sensitive !
def find_object_isin(parent, obj_type, desc):
	global svgname
	found = False

	for obj in parent.getElementsByTagName(obj_type):
	    if desc in get_desc(obj):
	        found = True
	        break
	
	if found == False:
	    print("%s: No node containing '%s' !" % (svgname, desc))
	    exit()

	return obj
	
def get_desc(obj):
	return obj.getElementsByTagName("desc")[0].firstChild.data

def get_num_attr(obj, attr):
	return float(obj.getAttribute(attr))
	
def get_fill_color(obj):
	style = obj.getAttribute("style")
	pos = style.find("fill:#")+6
	return style[pos:pos+6].lower()

def point_in_rect(p, rect):
	if p[0] < rect[0] or p[0] > rect[1]:
		return False
	if p[1] < rect[2] or p[1] > rect[3]:
		return False
	return True

def dprint(text):
	#print(text)
	return

if len(sys.argv) != 2:
	print("No input file specified.")
	exit()

celldefs = [os.path.splitext(f)[0] for f in os.listdir(".\Cells") if ".svg" in f]
print("Found %d cell defs: %s" % (len(celldefs), ", ".join(celldefs)))

pad_types = ["IN", "OUT", "OUZ", "UNK"]

cell_db = {}
for celldef in celldefs:
	svgname = celldef
	print("Processing " + svgname)
	doc = minidom.parse(".\Cells\\" + svgname + ".svg")

	# Get "Cell" layer
	layer = find_layer("Cell")
	
	# Get cell contour rect
	contour = find_object_isin(layer, "rect", "CONTOUR")
	
	# Get top-left corner coordinates
	origin_x = get_num_attr(contour, "x")
	origin_y = get_num_attr(contour, "y")
	width = get_num_attr(contour, "width")
	height = get_num_attr(contour, "height")
	# This is silly
	color = get_fill_color(contour)
	print("  Color: " + color)

	# Generate dict of pads with xmin, xmax, ymin, ymax, type
	pads = {}
	for pad in layer.getElementsByTagName('rect'):
		desc = get_desc(pad)
		if not "CONTOUR" in desc:
			for pad_type in pad_types:
				if pad_type in desc:
					x = get_num_attr(pad, "x") - origin_x
					y = get_num_attr(pad, "y") - origin_y
					w = get_num_attr(pad, "width")
					h = get_num_attr(pad, "height")
					name = desc
					if ' ' in desc:
						name = desc.split(' ')[1]
					pads[name] = [x, x + w, y, y + h, pad_type]
					break

	# Show pads by type
	for pad_type in pad_types:
		pad_list = []
		for pad in pads:
			if pads[pad][4] == pad_type:
				pad_list.append(pad)
		print("  %s pads: %s" % (pad_type, ", ".join(pad_list)))

	# Todo: Check that there's at least two UNK or (one IN and one OUT/OUZ) pads in cell
	# Todo: Check for overlapping pads
	# Todo: Check for duplicate pad names
		
	cell_db[svgname] = [width, height, color, pads]

	doc.unlink()


svgname = os.path.splitext(sys.argv[1])[0]

doc = minidom.parse(svgname + ".svg")

trace_layers = find_layers_type('T')
cell_layers = find_layers_type('C')

if len(trace_layers) == 0 or len(cell_layers) == 0:
	print("No trace or no cell layer !")
	exit()

# List cells
print("\nIdentifying cells in " + svgname)
cells = []
cell_count = 0
for layer in cell_layers:
	for cell in layer.getElementsByTagName('rect'):
		cell_id = cell.getAttribute("id").replace("cellrect", "")
		cell_x = get_num_attr(cell, "x")
		cell_y = get_num_attr(cell, "y")
		cell_w = get_num_attr(cell, "width")
		cell_h = get_num_attr(cell, "height")
		cell_color = get_fill_color(cell)
	    # Try to match cell to one in cell_db
	    # First with color
		matches = []
		for item in cell_db:
			if cell_color == cell_db[item][2]:
				matches.append(item)
	    # Then with closest size
		if len(matches) == 0:
			print("%s: unknown type !" % cell_id)
		else:
			item_best = -1
			# Find closest match
			delta_best = 1000
			for match in matches:
				delta_w = abs(cell_db[match][0] - cell_w)
				delta_h = abs(cell_db[match][1] - cell_h)
				delta = delta_w + delta_h
				if delta < delta_best:
					delta_best = delta
					item_best = match
			# Best delta too high, can't be a match
			if delta_best > 2:
				item_best = -1
	
			if item_best == -1:
				print("%s: unknown type !" % cell_id)
			else:
				print("%s is a %s (%d)" % (cell_id, item_best, delta_best))
				# Cell id from SVG (row/column coordinates), xmin, xmax, ymin, ymax, cell type (from cell_db), connections dictionary, pointlist
				# Connections dictionary: key is pad_id, value is trace_id
				# Pointlist is used later for cell flip detection
				conn_dict = {}
				# Pads are all set as unconnected
				for pad in cell_db[item_best][3]:
					conn_dict[pad] = ""
				# Traces point list starts empty
				pointlist = []
				cells.append([cell_id, cell_x, cell_x + cell_w, cell_y, cell_y + cell_h, item_best, conn_dict, pointlist])
		cell_count += 1
		if cell_count == cell_parse_limit:
			break
	if cell_count == cell_parse_limit:
		break

# List traces and process their path commands
# For each of the trace's nodes, check if it lands inside a cell
# If it does, check if it lands on one of the cell's pads
print("\nProcessing traces in " + svgname)

profiling_ref_total = perf_counter_ns()	# PROFILING

breakpoint = False

do_exit = False
trace_count = 0
traces = {}
for layer in trace_layers:
	for trace in layer.getElementsByTagName('path'):
		trace_id = trace.getAttribute("id")
		d = trace.getAttribute("d")
		cur_x = cur_y = 0
		
		print("%s:" % trace_id)

		connections = []
		commands = d.split(' ')
		i = 0
		node_index = 0
		while i < len(commands):
			command = commands[i]
	
			if not command[0].isalpha():
				# New command is implicit
				if last_command == "M":
					command = "L"
				elif last_command == "m":
					command = "l"
				else:
					command = last_command
			else:
				i += 1
	
			#print(command)	# Debug
			if command == "m":
				dx = 0
				dy = 0
				coords = commands[i].split(',')
				if i == 1:
					# Very first command is a MoveTo relative - treat as MoveTo absolute
					#dprint("First MoveTo relative " + coords[0] + "," + coords[1])
					cur_x = float(coords[0])
					cur_y = float(coords[1])
				else:
					#dprint("MoveTo relative " + coords[0] + "," + coords[1])
					cur_x += float(coords[0])
					cur_y += float(coords[1])
				i += 1
			elif command == "M":
				dx = 0
				dy = 0
				coords = commands[i].split(',')
				cur_x = float(coords[0])
				cur_y = float(coords[1])
				i += 1
			elif command == "h":
				#dprint("LineTo horizontal relative " + commands[i])
				dx = float(commands[i])
				dy = 0
				i += 1
			elif command == "H":
				#dprint("LineTo horizontal absolute " + commands[i])
				dx = float(commands[i]) - cur_x
				dy = 0
				i += 1
			elif command == "v":
				#dprint("LineTo vertical relative " + commands[i])
				dx = 0
				dy = float(commands[i])
				i += 1
			elif command == "V":
				#dprint("LineTo vertical absolute " + commands[i])
				dx = 0
				dy = float(commands[i]) - cur_y
				i += 1
			elif command == "l":
				coords = commands[i].split(',')
				#dprint("LineTo relative " + coords[0] + "," + coords[1])
				dx = float(coords[0])
				dy = float(coords[1])
				i += 1
			elif command == "L":
				coords = commands[i].split(',')
				#dprint("LineTo absolute " + coords[0] + "," + coords[1])
				dx = float(coords[0]) - cur_x
				dy = float(coords[1]) - cur_y
				i += 1
			elif command == "c":
				# Treat as straight line
				coords = commands[i+2].split(',')
				#dprint("LineTo cubic Bezier " + coords[0] + "," + coords[1])
				dx = float(coords[0])
				dy = float(coords[1])
				i += 3
			else:
				print("Unknown command " + command)
				print(d)
				do_exit = True
				break

			cur_x += dx
			cur_y += dy

			#if command == "v" and dy == 14.26552 and trace_id == "path29548":
			#if command == "M" and float(coords[0]) == 357.05872 and trace_id == "path29548":
			#if command == "m" and float(coords[0]) == 59.44743 and trace_id == "path29548":
				# After M 357.05872,391.43299: 357.05..., 391.43... OK :)
				# After m 59.44743,-60.47642: 66.55..., -54.48... NOK :(
				#print("Breakpoint !")
				#print(cur_x)
				#print(cur_y)
				#breakpoint = True

			#dprint("  Node %d:" % node_index)
			#dprint("    %d, %d" % (cur_x, cur_y))

			# See if node is inside a cell (slow)
			connected = False
			j = 0
			for cell in cells:
				#2.559635242s total using dict for "cells"
				#0.183661841s total using list for "cells"

				#if point_in_rect(cur_coords, cell[0:4]):
				#if cur_coords[0] > cell[0] and cur_coords[0] < cell[1] and cur_coords[1] > cell[2] and cur_coords[1] < cell[3]:
				if cell[1] < cur_x < cell[2] and cell[3] < cur_y < cell[4]:	# fastest
					#print("%s has a point inside cell %s" % (trace_id, cell[0]))

					matched_cell = cell_db[cell[5]]
					# Make current node position relative to cell
					cur_x_rel = cur_x - cell[1]
					cur_y_rel = cur_y - cell[3]

					# Node is in cell, add to cell's point list
					cells[j][7].append((trace_id, cur_x_rel, cur_y_rel))

					# See if node lands on a pad of the cell
					for pad_id in matched_cell[3]:
						pad = matched_cell[3][pad_id]
						if point_in_rect([cur_x_rel, cur_y_rel], pad[0:4]):
							#print("  %s(%s).%s" % (item, matched_cell[0], pad_id))
							# Add the connection (cell id, pad id) tuple to the trace
							connections.append((cell[0], pad_id))
							# Add the trace id to the cell's pad
							# Todo: Check for pad already connected
							cells[j][6][pad_id] = trace_id
							connected = True
							break

				j += 1
				if connected == True:
					break

			last_command = command
			node_index += 1

		traces[trace_id] = connections
		trace_count += 1

		if do_exit == True:
			exit()

		if trace_count == trace_parse_limit:
			break
		#if trace_id == "path29548": exit()
	if trace_count == trace_parse_limit:
		break
		
# Look for possibly flipped cells
for cell in cells:
	pads = cell[6]
	total_pads = len(pads)
	unconnected_pads = 0
	for pad in pads:
		if pads[pad] == "":
			unconnected_pads += 1

	if unconnected_pads / total_pads > 0.5:
		# More than 50% of the pads aren't connected
		if len(cell[7]) >= unconnected_pads:
			# There are more missed points than unconnected pads, cell might be flipped
            # Try flipping it and see if it makes more pads connected

			# Loop through the cell's pads from cell_db
			# xmin = cell_width - pad_width - x
			# xmax = xmin + pad_width
			# Same ymin and ymax as normal (only handle x flip)
			# Loop through landing point coordinates (cur_x, cur_y) and see if they now land in the flipped pad
			print("Cell %s isn't very connected :(" % cell[0])
			#print(pads)
			new_connections = []
			cell_type = cell[5]
			pads = cell_db[cell_type][3]	# Same as cell[6]
			cell_width = cell_db[cell_type][0]
			for pad_id in pads:
				pad = pads[pad_id]
				pad_width = pad[1] - pad[0]				# xmax - xmin
				xmin = cell_width - pad_width - pad[0]	# = cell_width - xmax - (2 * xmin)
				xmax = xmin + pad_width
				ymin = pad[2]
				ymax = pad[3]
				#print("  pad_id: %s [%d, %d, %d, %d]" % (pad_id, xmin, xmax, ymin, ymax))
				for point in cell[7]:
					#print("  Point at %d,%d" % (point[1], point[2]))
					if point_in_rect([point[1], point[2]], [xmin, xmax, ymin, ymax]):
						#print("    Is connected to trace %s" % point[0])
						new_connections.append((pad_id, point[0]))

			#print("Previous connected pads: %d" % (total_pads - unconnected_pads))
			#print("New connected pads: %d" % len(new_connections))
			if len(new_connections) > (total_pads - unconnected_pads):
				print("  More connections when flipped !")
				pads = cell[6]
				# Update traces: remove wrong connections
				for pad_id in pads:
					trace_id = cell[6][pad_id]
					if trace_id != "":
						# Connected pad
						# Remove trace -> pad entry
						traces[trace_id].remove((cell[0], pad_id))
						print("    Removed trace connection")
				# Update cell's pads
				for connection in new_connections:
					print("    Added trace connection")
					cell[6][connection[0]] = connection[1]
					# Update traces: add correct connection
					traces[connection[1]].append((cell[0], connection[0]))

profiling_total = (perf_counter_ns() - profiling_ref_total)	# PROFILING

# Export netlist data
filename = svgname + "_netlist.bin"

# Todo: strip cur_x, cur_y from cells pad connections - Takes space and not needed for further processing
# Convert "cells" from list to dict for easier access
cells_dict = {}
for cell in cells:
	cells_dict[cell[0]] = cell[1:8]	#cell[1:7]
netlist = [svgname, cell_db, cells_dict, traces]

f_out = open(filename, "wb")
f_out.write(msgpack.packb(netlist, use_bin_type=True))

doc.unlink()

print("\nCells: %d (%d%% known)" % (len(cells), int(100 * len(cells) / cell_count)))
print("Traces %d" % len(traces))
print("Generated " + filename)

print(profiling_total)
# 131.886408281s 2m11s
