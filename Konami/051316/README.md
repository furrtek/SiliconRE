# Konami 051316

"PSAC" ROZ plane generator.

Fujitsu gate array with embedded RAM.

* CA0-3: XACC[14:11] with optional flipping
* CA7-4: YACC[14:11] with optional flipping
* CA15-8: RAM_R_D[7:0] (tile code low)
* CA23-16: RAM_L_D[7:0] (tile code high)

# X adder:

* A[7:0]: REG3 or REG5
* B[7:0]: XACC[7:0] or XPREV[7:0]
* A[23:8]: REG2 or REG4, sign-extended
* B[23:8]: {REG0, REG1} or XACC[23:8] or XPREV[23:8]

Load: W119 {REG0, REG1, 00}

Acc: W148

Pixel inc: E34_1 {00, REG2, REG3}

Line inc: /E34_1 {00, REG4, REG5}

# Registers

* 0-1: X start MSBs
* 2-3: X pixel inc
* 4-5: X line inc
* 6-7: Y start MSBs
* 8-9: Y pixel inc
* A-B: Y line inc
* C-D: ROM bank during test readout (bits [12:0])
* E:
  * Bit 0: Enable ROM readout (active low)
  * Bit 1: Enable tile X flip when tile code bit 14 is set
  * Bit 2: Enable tile Y flip when tile code bit 15 is set
  * Bit 3: Enable clock test output on OBLK pin
  * Bit 4-5: Internal clock select
  * Bit 6: Enable test mode (direct counter output on CA23-0, select which with bit 0)
  * Bit 7: Enable test mode (direct RAM output on CA23-16, select block with A10)
* F: Unmapped

# Pinout

* 1, 5, 6, 47, 49: NC
* 3, 16, 35, 48: GND
* 32, 64: VCC
* 2: 12MHz in
* 4: OBLK out
* 7-15, 17-31: Graphics ROM address out
* 33: IOCS registers select
* 34: VRCS RAM select
* 36-46: CPU address in
* 50-57: CPU data in/out
* 58: CPU RW in
* 59: VSCN in
* 60: HSCN in
* 61: VRC in
* 62: HRC in
* 63: 6MHz in
