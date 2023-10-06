# Performs ERC on a previously generated netlist
# Netlist format:
# [name, cell_db, cells, traces]
# 	svgname: Filename of the input svg without extension
#	cell_db: {cell_id : width, height, color, pads}
#		pads: {pad_id : xmin, xmax, ymin, ymax, pad_type}
#		pad_type: IN, OUT, OUZ, or UNK
#	cells: {cell_id : [cell_x, cell_x + cell_w, cell_y, cell_y + cell_h, cell_id, conn_dict]}
#		index: index into cell_db (cell type)
#		conn_dict: {pad_id : trace_id}
#	traces: {trace_id : [connections]}
#		connections: [(cell_id, pad_id)]

import os
import sys
import msgpack

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

pad_types = ["IN", "OUT", "OUZ", "UNK"]

f_in = open(sys.argv[1], "rb")

netlist = msgpack.unpackb(f_in.read())
#netlist = [svgname, cell_db, cells, traces]
cell_db = netlist[1]
cells = netlist[2]
traces = netlist[3]

print("ID ?")
inp = input()

if "path" in inp:
	trace = traces[inp]
	for connection in trace:
		print("Connected to %s.%s" % (connection[0], connection[1]))
else:
	inp = inp.upper()
	cell = cells[inp]
	print("%s is a %s" % (inp, cell[4]))
	for pad_id in cell[5]:
		trace_id = cell[5][pad_id]
		trace_info = ""
		if trace_id != "":
			trace = traces[trace_id]
			for connection in trace:
				if connection[0] != inp:
					trace_info += ("to " + connection[0] + "." + connection[1] + ", ")
		print("Pad %s -> %s (%s)" % (pad_id, trace_id, trace_info))
	#print(cell[6])


exit()

# Todo: export connectivity issues report

# Check traces for connectivity issues
# More than one OUT: multiple drivers
# No OUT and no OUZ: not driven
# OUT and OUZ: mixed drivers, should be single OUT, or multiple OUZ with no OUT
# No IN and no UNK: driven but no inputs
print("\nTrace connectivity issues:")

for trace_id in traces:
	connections = traces[trace_id]

	conn_count = {}
	for pad_type in pad_types:
		conn_count[pad_type] = 0

	for connection in connections:
		cell_id, pad_id = connection
		cell_type = cells[cell_id][4]	# Index
		pad_type = cell_db[cell_type][3][pad_id][4]
		
		conn_count[pad_type] += 1

	if conn_count["OUT"] > 1:
		print("%s: Multiple drivers !" % trace_id)
	if conn_count["OUT"] == 0 and conn_count["OUZ"] == 0:
		print("%s: No driver !" % trace_id)
	if conn_count["OUT"] > 0 and conn_count["OUZ"] > 0:
		print("%s: Mixed drivers and tristate drivers !" % trace_id)
	if conn_count["IN"] == 0 and conn_count["UNK"] == 0:
		print("%s: Driven but no inputs !" % trace_id)

# Check cells for connectivity issues
# OUT not connected: warning
# No OUT connected: error
# OUTZ not connected: error
# IN not connected: error
# UNK not connected: warning
print("\nCell connectivity issues:")
for item in cells:
	cell = cells[item]
	for pad in cell[5]:
		if cell[5][pad] == "":
			print("%s.%s not connected" % (item, pad))

exit()
