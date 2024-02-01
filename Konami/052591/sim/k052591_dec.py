# Konami 052591 decoder/disassembler
# 2024 furrtek

import sys

lut_in = ["rega,Acc", "rega,regb", "#0,Acc", "#0,regb", "#0,rega", "i/r,rega", "i/r,Acc", "i/r,#0"]
lut_opname = ["Add", "Add", "Add", "Or", "And", "?", "?", "?"]
lut_cc = ["z", "c", "o", "n"]

# Spacing for instruction binary display
bit_spaces = [2, 5, 8, 11, 14, 15, 23, 26, 28, 31, 33]

def bit(n, c):
	return int(bin_str[35 - n]) == c
	
def pad(s, n):
	while (len(s) < n):
		s += " "
	return s
	
lines = []
lineskips = []

fn_in = sys.argv[1]
fn_out = fn_in + ".txt"

with open(fn_in, "rb") as f:
	iram = f.read()

f = open(fn_out, "w")

# Header
f.write(fn_in + "\n")
f.write("              33 33 332 22 222 22221111 1 111 11               (Imm and PC values are in hex)\n")
f.write("Addr          54 32 109 87 654 32109876 5 432 109 876 543 210  ALUA  ALUB Op  Dst    S/R I Branch    RamM Ext      Ctrl  Next      Code\n\n")

for a in range(0, 64):
	decoded_str = "{:02x}: ".format(a)

	# Bytes to 36-bit word
	i = a * 5
	byte = iram[i + 4] & 15
	hex_str = "{:01x}".format(byte)	# First nibble
	bin_str = "{:04b}".format(byte)
	for b in range(0, 4):
		byte = iram[i + 3 - b]
		hex_str += "{:02x}".format(byte)
		bin_str += "{:08b}".format(byte)

	# Instruction in hex
	decoded_str += pad(hex_str, 10)

	bin_str_sp = bin_str
	for space in bit_spaces:
		index = 35 - space
		bin_str_sp = bin_str_sp[:index] + ' ' + bin_str_sp[index:]

	# Instruction in binary
	decoded_str += pad(bin_str_sp, 49)

	# Register names from bitfields
	rega = "r{:01d}".format((iram[i + 1] >> 1) & 7)
	regb = "r{:01d}".format((iram[i + 1] >> 4) & 7)

	# ALU operation
	alu_opcode = (iram[i] >> 3) & 7
	alu_isarithmetic = (alu_opcode <= 2)

	# Shift/rotate
	sr_shift = bit(33, 1)
	sr_en = bit(8, 1)
	sr_left = bit(7, 1)

	# Immediate value (12-bit)
	imm = ((iram[i + 3] & 15) << 8) + iram[i + 2]
	if bit(28, 1):
		imm |= 0xF000	# Sign bit

	# External interface data/address latch udpate
	# IR31 IR30
	#  0    0	Update ext RAM data with ext_value LSB
	#  0    1	Update ext RAM data with ext_value MSB
	#  1    0	Update ext RAM address with ext_value
	#  1    1	No update
	ext_update = ""
	if bit(31, 0):
		if bit(30, 0):
			ext_update = "D=val(L)"
		else:
			ext_update = "D=val(U)"
	else:
		if bit(30, 0):
			ext_update = "A=val"

	# ext_value can come from reg A or ALU
	ext_value_rega = bit(8, 0) and bit(7, 1) and bit(6, 0)	# Otherwise ALU
	ext_update = ext_update.replace("val", rega if ext_value_rega else "ALU")

	# Accumulator can be an additionnal destination
	acc_update = not (bit(8, 0) and bit(7, 1)) and bit(6, 0)

	# ALU A input pre-mux
	# IR35 IR15
	#  0    0	ALU A pre-mux output is RAM data, latch RAM data byte in MSB register
	#  0    1   ALU A pre-mux output is RAM data
	#  1    0   ALU A pre-mux output is RAM data, MSB is zero
	#  1    1   ALU A pre-mux output is immediate
	set_msb = False

	if bit(35, 0) and bit(15, 0):
		imm_ram = "Ram"
		set_msb = True
	elif bit(35, 0) and bit(15, 1):
		imm_ram = "RamW"
	elif bit(35, 1) and bit(15, 0):
		imm_ram = "RamB"
	elif bit(35, 1) and bit(15, 1):
		imm_ram = pad("#{:x}".format(imm), 4)	# Immediate

	# IR15=0: Set future ext interface control levels with IR28 (/OE) and IR27 (/WE)
	if bit(15, 0):
		ext_set = True
		ext_next_oe = bit(28, 1)
		ext_next_we = bit(27, 1)
	else:
		ext_set = False

	# IR29=0: Apply previously set levels to ext interface control pins
	ext_apply = bit(29, 0)

	# PIN_OUT0 is set to IR16 (immediate bit 0) when IR15=1 and IR34=0
	out0_set = bit(15, 1) and bit(34, 0)
	out0_level = bit(16, 1)

	# Decode ALU inputs
	alu_incode = iram[i] & 7
	alu_in = lut_in[alu_incode]
	alu_in = alu_in.replace("i/r", imm_ram)
	alu_in = alu_in.replace("rega", rega)
	alu_in = alu_in.replace("regb", regb)
	alu_in = alu_in.split(",")

	if alu_isarithmetic:
		if alu_opcode & 1:
			alu_in[0] = "~" + alu_in[0]	# Invert ALU A input
		if alu_opcode & 2:
			alu_in[1] = "~" + alu_in[1]	# Invert ALU B input

	# Destination
	if bit(7, 1) or bit(8, 1):
		dest = regb
	else:
		dest = ""

	# ALU carry in, used for subtraction
	if bit(32, 0) or bit(33, 1):
		#N68_next = False
		cond_sub = False
		alu_cin = bit(34, 1) and bit(15, 0) and alu_isarithmetic
	else:
		#N68_next = True if ALU result is negative, used for division algorithm
		cond_sub = True
		alu_cin = bit(3, 1) #or N68_next

	# Branching
	# IR15=1: No jump, continue to next instruction
	# IR15=0:
	# IR26 IR25 IR24
	# 000 Conditional Call Imm
	# 001 Conditional Jump Imm
	# 010 Conditional Ret
	# 011 Next
	# 100 Call Imm
	# 101 Jump Imm
	# 110 Ret
	# 111 Jump to Initial PC

	addr = iram[i + 2] & 0x3F	# Branch address is part of immediate field
	conditional = False
	if bit(15, 1):
		branch = ""
	else:
		if bit(26, 1):
			if bit(25, 1):
				if bit(24, 1):
					branch = "jp   Init"
				else:
					branch = "ret"
					lineskips.append(a)
			else:
				lineskips.append(addr - 1)
				if bit(24, 1):
					branch = "jp   imm"
				else:
					branch = "call imm"
		else:
			if bit(25, 1):
				if bit(24, 1):
					branch = ""	# Next
				else:
					conditional = True
					branch = "ret  cc"
					lineskips.append(a)
			else:
				conditional = True
				lineskips.append(addr - 1)
				if bit(24, 1):
					branch = "jp   cc,imm"
				else:
					branch = "call cc,imm"

	# Insert condition code if needed
	cc = lut_cc[(iram[i + 2] >> 6) & 3]
	branch = branch.replace("cc", cc)
	# Insert address value if needed
	branch = branch.replace("imm", "{:02x}".format(addr))

	# Compose rest of decoded string
	decoded_str += pad(alu_in[0], 6)					# ALU A input
	decoded_str += pad(alu_in[1], 5)					# ALU B input
	decoded_str += pad(lut_opname[alu_opcode], 4)		# ALU operation type
	if dest:                                            # ALU destination
		decoded_str += pad(dest + (",Acc" if acc_update else ""), 7)
	else:
		decoded_str += pad("Acc" if acc_update else "", 7)

	# Shift/rotate symbol
	sr_str = ""
	if sr_en:
		sr_char = "<" if sr_left else ">"
		sr_str = sr_char * (2 if sr_shift else 3)
	decoded_str += pad(sr_str, 4)

	# ALU carry in or conditional add/sub symbol
	decoded_str += pad("+" if alu_cin else "~" if cond_sub else "", 2)

	decoded_str += pad(branch, 10)						# Branch operation
	decoded_str += pad("Set" if set_msb else "", 5)		# MSB latch set
	decoded_str += pad(ext_update, 9)					# External interface address/data update
	decoded_str += pad("Apply" if ext_apply else "", 6)	# External interface control signals update

	# External interface future control signals set or OUT0 pin level set (both are mutually exclusive)
	ext_str = ""
	if ext_set:
		ext_str = "OE=" + ("1" if ext_next_oe else "0")
		ext_str += (" WE=" + ("1" if ext_next_we else "0"))
	else:
		# OUT0 pin state update
		ext_str = pad("OUT0=" + ("1" if out0_level else "0") if out0_set else "", 7)

	decoded_str += pad(ext_str, 10)


	# Decode some instructions to assembly-like code
	instruction = ""
	mnemo = ""

	if acc_update:
		dest_str = "Acc"
		if dest:
			dest_str += (","  + dest)
	else:
		dest_str = dest

	if bit(31, 1) and bit(30, 0):
		# Update ext RAM address
		if ext_value_rega:
			instruction = "ld   ExtAddr," + rega	# From register (before any ALU op)
		else:
			instruction = "ld   ExtAddr,ALU"		# From ALU
	elif bit(31, 0):
		# Update ext RAM data
		ext_data_upper = bit(30, 1)
		dest_str += (("," if dest_str != "" else "") + "ExtData")

	if set_msb:
		# Update internal MSB latch
		instruction = "ld   MSB,[ExtAddr]"

	if bit(35, 1) and bit(15, 1):
		if alu_opcode == 1 or alu_opcode == 2:
			imm += 1	# Mnemo will be Sub, inverted immediate + 1
		imm_ram = "#{:x}".format(imm & 1 if out0_set else imm)	# Only lowest bit of immediate used if setting OUT0 pin level
	else:
		imm_ram = "[ExtAddr]" + ("b" if bit(35, 1) and bit(15, 0) else "w")

	if sr_en:
		imm_ram += (sr_str + "1")

	if alu_incode == 0:		# Rega, Acc
		src_str = rega + ",Acc"
	elif alu_incode == 1:	# Rega, RegB
		src_str = rega + "," + regb
	elif alu_incode == 2 or alu_incode == 3 or alu_incode == 4:	# #0 or !#0, RegX
		if alu_incode == 2:
			src_str = "Acc"
		elif alu_incode == 3:
			src_str = regb
		else:
			src_str = rega
		if alu_opcode & 1 and alu_isarithmetic:
			src_str += ",#ffff"
	elif alu_incode == 5:	# I/R, rega
		src_str = imm_ram + "," + rega
	elif alu_incode == 6:	# I/R, Acc
		src_str = imm_ram + ",Acc"
	elif alu_incode == 7:	# I/R, #0
		src_str = imm_ram

	if alu_opcode == 0:
		# ALU op is Add
		if cond_sub:
			mnemo = "a/s"
		else:
			mnemo = "add"

		if alu_cin:
			src_str += ",#1"
			if alu_incode == 2 and dest_str == "Acc":	# #0, acc
				mnemo = "inc"
				src_str = ""
			elif alu_incode == 3 and dest == regb:	# #0, regb
				mnemo = "inc"
				src_str = ""
			elif alu_incode == 4 and dest == rega:	# #0, rega
				mnemo = "inc"
				src_str = ""
	elif alu_opcode == 1 or alu_opcode == 2:
		# ALU op is Sub, really an Add with one of the inputs inverted
		mnemo = "sub"
		if alu_cin:
			if dest_str == "":
				mnemo = "cmp"
			if alu_opcode == 1:	# ALU op is !A+B+1 = B-A, otherwise op is A+!B+1 = A-B
				 # Flip ALU inputs
				 temp = src_str.split(",")
				 src_str = temp[1] + "," + temp[0]
		else:
			if alu_opcode == 1:	# ALU A inverted
				if alu_incode == 2 and dest_str == "Acc":	# ~#0, acc
					mnemo = "dec"
					src_str = ""
				elif alu_incode == 3 and dest == regb:	# ~#0, regb
					mnemo = "dec"
					src_str = ""
				elif alu_incode == 4 and dest == rega:	# ~#0, rega
					mnemo = "dec"
					src_str = ""
	elif alu_opcode == 3:
		# ALU op is OR
		if alu_incode == 2 or alu_incode == 3 or alu_incode == 4 or alu_incode == 7:
			# One of the ALU inputs is #0
			if dest_str:
				mnemo = "ld"	# We have an immediate or RAM load
			else:
				mnemo = "tst"	# No destination, we're just testing for zero
		else:
			mnemo = "or"	# Both ALU inputs can be non-zero, we have a OR
	elif alu_opcode == 4:
		if alu_incode == 7:
			mnemo = "clr"	# ALU op is AND with B input = 0
			src_str = ""
		else:
			mnemo = "and"	# ALU op is AND
	elif alu_opcode == 7:
		mnemo = "ld"	# Really nop, used for setting OUT0 pin level
	else:
		mnemo = "?"	# ALU op is unknown

	if "ExtData" in dest_str:
		src_str += ("(U)" if ext_data_upper else "(L)")

	if out0_set:
		dest_str = "OUT0"
	else:
		if dest_str == "" and not conditional:
			# If there is no destination register and branch isn't conditional, net result is nop
			mnemo = "nop"
			dest_str = ""
			src_str = ""

	if src_str != "" and dest_str:
		src_str = "," + src_str

	if instruction != "":
		instruction = pad(instruction, 22)

	if mnemo != "":
		mnemo = pad(mnemo, 5)
		instruction += pad(mnemo + dest_str + src_str, 22)
	instruction += branch

	lines.append(decoded_str + "{:02x}: ".format(a) + instruction)

a = 0
for line in lines:
	f.write(line + "\n")
	if a in lineskips:
		f.write("\n")
	a += 1

print("Wrote " + fn_out)

f.close()
