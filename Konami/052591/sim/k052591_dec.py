fn = "thunderxa.bin"

lut_in = ["RegA Acc  ", "RegA RegB ", "0    Acc  ", "0    RegB ", "0    RegA ", "I/R  RegA ", "I/R  Acc  ", "I/R  0    "]

lut_op = ["Add ", "Add ", "Sub ", "OR  ", "AND ", "?   ", "?   ", "?   "]

def bit(n, c):
	global binstr
	return 1 if int(binstr[35 - n]) == c else 0

with open(fn, "rb") as f:
	iram = f.read()

f = open("dec.txt", "w")

f.write(fn + "\n")
f.write("A   Instruction                                    s ALUA ALUB Op  Wr I PC   Ex\n")

for a in range(0, 64):
	dispstr = "{:02x}: ".format(a)
	i = a * 5

	byte = iram[i + 4] & 15
	hexstr = "{:01x}".format(byte)
	binstr = "{:04b}".format(byte)
	for b in range(0, 4):
		byte = iram[i + 3 - b]
		hexstr += "{:02x}".format(byte)
		binstr += "{:08b}".format(byte)

	dispstr += (hexstr + " ")
	dispstr += (binstr + " ")

	if bit(35, 1) & bit(15, 0):
		dispstr += "b "
	else:
		dispstr += "W "

	#rega = (iram[i + 1] >> 1) & 7
	#dispstr += "r{:01d} ".format(rega)
	#regb = (iram[i + 1] >> 4) & 7
	#dispstr += "r{:01d}".format(regb)
	#if bit(7, 1) | bit(8, 1):
	#	dispstr += "! "
	#else:
	#	dispstr += "  "
	
	rega = "r{:01d}".format((iram[i + 1] >> 1) & 7)
	regb = "r{:01d}".format((iram[i + 1] >> 4) & 7)

	#if bit(8):
	#	dispstr += "SR "

	#if bit(6, 0) and not (bit(8, 0) and bit(7, 1)):
	#	dispstr += "A "	# Write to acc
	#else:
	#	dispstr += "  "

	imm = ((iram[i + 3] & 15) << 8) + iram[i + 2]
	if bit(28, 1):
		imm = -imm
	if bit(35, 1) and bit(15, 0):
		imm = imm & 0xFF

	if bit(35, 1) and bit(15, 1):
		imm_ram = "{:03x}".format(imm)	# ALU A input, immediate
	else:
		imm_ram = "Ram"

	# ALU inputs
	alu_in = lut_in[iram[i] & 7]
	alu_in = alu_in.replace("I/R", imm_ram)
	alu_in = alu_in.replace("RegA", rega + "  ")
	alu_in = alu_in.replace("RegB", regb + "  ")
	dispstr += alu_in

	# ALU op
	dispstr += lut_op[(iram[i] >> 3) & 7]

	# Result destination
	if bit(7, 1) | bit(8, 1):
		dest = regb
	else:
		dest = ""
	if bit(6, 0) and not (bit(8, 0) and bit(7, 1)):
		dest += "A"	# Write to acc
	else:
		dest += " "
	while (len(dest) < 3):
		dest = dest + " "
	dispstr += dest

	# Increment
	if (bit(32, 0) or bit(33, 1)) and bit(34, 1) and bit(15, 0):
		dispstr += "+ "
	elif bit(32, 1) and bit(33, 0) and bit(3, 1):
		dispstr += "+ "
	else:
		dispstr += "  "

	# ir26=1: Unconditional jump
	# ir15=0 \
	# ir25=0  |: Jump
	# ir24=1 /

	addr = iram[i + 2] & 0x3F

	# This must be wrong
	if bit(26, 1) and (bit(25, 0) or bit(24, 1)) and bit(15, 0):
		dispstr += "Jp{:02x} ".format(addr)

	if bit(26, 0) and bit(25, 0) and bit(24, 1) and bit(15, 0):
		if bit(23, 0) and bit(22, 0):
			dispstr += "Jz{:02x} ".format(addr)
		elif bit(23, 1) and bit(22, 1):
			dispstr += "Jp{:02x} ".format(addr)
		else:
			dispstr += "Jc{:02x} ".format(addr)
	else:
		dispstr += "Next "

	# Ext RAM data direction
	if bit(29, 1):
		dispstr += "r "	# Read
	else:
		# Ext RAM write when IR27=0 IR15=0
		if bit(15, 0) and bit(27, 0):
			dispstr += "w "	# Write
		else:
			dispstr += "  "

	if bit(31, 0):
		# Update ext RAM data
		if bit(30, 1):
			dispstr += "H"	# Ext RAM data high/low select
		else:
			dispstr += "L"	# Ext RAM data high/low select
	else:
		if bit(30, 1):
			dispstr += " "
		else:
			# Ext RAM address is updated to PTR
			if (iram[i] >> 6) == 0b010:
				dispstr += ("A:" + rega)
			else:
				dispstr += "A:ALU "

	# PIN_OUT0 is set with ir16 when ir15=1 and ir34=0
	if bit(15, 1) and bit(34, 0):
		dispstr += "OUT={:d}".format(bit(16, 1))

	f.write(dispstr + "\n")

f.close()
