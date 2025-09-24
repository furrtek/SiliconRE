# Konami 054539

 * Manufacturer: Fujitsu
 * Type: Standard cell, RAM, ROM, multipliers
 * Die markings: 87821
 * Die picture: https://siliconpr0n.org/map/konami/054539...
 * Function: PCM sound
 * Used in:
 Pirate Ship, Polygonet, Premier Soccer, Pontoon, G.I. Joe, Lethal Enforcers, Run and Gun,
 Wild West C.O.W. boys of Moo Mesa, X-Men, Ultra Sports, Xexex, Slam Dunk, Racing Force,
 Metamorphic Force, Martial Champions, Mystic Warriors, Gaiapolis, Violent Storm, Monster Maulers, ...
 * Chip donator: Own

External reverb RAM, address and data bus shared with PCM samples ROM. Can work in pairs.
Can reverb RAM be shared ?

Pinout from Racing Force schematics.

TODO: Check DFFSQs, they're probably DFFRQs (the /set is behind the output inverter).

Channel data in 00~FF is stored in two 128-byte odd/even RAM blocks with full read/write access. Several addresses are used for internal storage of channel state and values. Access slots are tightly interleaved (1/4) so there's no CPU access delay.
The current internal RAM access address comes from a lookup table stored in ROM A, which is read in a linear way during a 384-cycle (32 * 12) period.

Samplerate:
Racing Force TOPCK = 18MHz
Soccer Superstars = 18.43200MHz

ROMA: 384 * 7 bits
ROMB: 192 * 16 bits

MULA: 8 * 16 = 24 LSB
MULB: 16 * 16 = 16 MSB

# Data paths

 * Bidirectional path between DB[7:0] and RD[7:0], for POST of external RAM.
 * Bidirectional path between RAM_A_DOUT[7:0]/RAM_A_DIN[7:0] and DB[7:0], for CPU access of odd values.
 * Bidirectional path between RAM_B_DOUT[7:0]/RAM_B_DIN[7:0] and DB[7:0], for CPU access of even values.
 * Path from ROMA_D[6:0] to RA[6:0], for factory testing of ROMA.
 * Path from ROMB_D[15:0] to RA[15:0], for factory testing of ROMB.

 * Path from RD[7:0] to MULA_A[7:0], for factory testing (TESTREG1_D3).
 * Path from {AB[7:0], DB[7:0]} to MULA_B[15:0], for factory testing (TESTREG1_D3).
 * Path from MULA_OUT[23:0] to RA[23:0], for factory testing.

 * Path from {AXXA, AXDA, ALRA, AXWA, RRMD, USE2, DTS2, DTS1, RD[7:0]} to MULB_A[15:0], for factory testing (TESTREG1_D1).
 * Path from {AB[7:0], DB[7:0]} to MULB_B[15:0], for factory testing (TESTREG1_D1).
 * Path from MULB_OUT[15:0] to RA[15:0], for factory testing.

# Adders

ADDERA 40-bit pitch accumulator ? Value is stored in internal RAM
ADDA[39:32]	RAMA
ADDA[31:24]	RAMA
ADDA[23:16]	RAMB
ADDA[15:8]	RAMA
ADDA[7:0]	RAMB
Adds {0, 0, MUXB, MUXA, MUXB} (24 bits) to {MUXA, MUXA, MUXB, MUXA, MUXB} (40 bits)
Top 24 bits of {MUXA, MUXA, MUXB, MUXA, MUXB} used as address offset

ADDERB 24-bit adds channel start address + offset for ext address output.

{RD_REG[7:0], RD_REG2[7:0]} can go to MUXD[15:0].

ADDERD used for DPCM step ?

# Sample data

MAME:
Even[3:2]=00: 8-bit PCM, end of sample marked as 0x80.
Even[3:2]=01: 16-bit PCM, end of sample marked as 0x8000.
Even[3:2]=10: 4-bit DPCM, end of sample marked as 0x88.

End of samples marked as 0x80 or 0x8000.

# Mixer

Channel mixer / accumulator: 10 bit (MULA_OUT[23:14]) + 24 bit (MULA_OUT[23:0])

Output mixer / accumulator: three pairs of 16 bit registers (MULB_OUT[15:0] + REGEA/B/C/D/E/F)
Three final outputs * 2 channels
REGED ends up in the FRDL PISO
REGEB ends up in the FRDT PISO
REGEC ends up in the REDL PISO
REGEA ends up in THE REDT PISO
REGEE and REGEF end up in the final output PISO

# Test registers

Two 8-bit test registers set to DB[7:0] by posedge on TS1 and TS2 pins, which are hardwired low on game boards. Both are cleared on reset.

## TESTREG1

Bit 0: Forces S109 = S121 = 1.
Bit 1: Forces S109 = S121 = 1. MULB test.
Bit 2: Forces S109 = S121 = 1.
Bit 3: Forces S109 = S121 = 1. MULA test.
Bit 4: Forces S109 = S121 = 1.
Bit 5: Forces S109 = S121 = 1.
Bit 6: Uses pins RRMD, ADDA, and USE2 as alternate inputs for ?.
Bit 7: Selects source for ROMA_A8.

## TESTREG2

Bit 0: Routes {RD[7:0], DB[7:0]} to {MUX_A, MUX_B}.
Bit 1: Sets TIMER clock source to CLKDIV2D.
Bit 2: Forces S109 = S121 = 1.
Bit 3: Splits internal address counter in 4 blocks, clocks them with CLKDIV2D.
Bit 4: Forces S109 = S121 = 1.

# Registers

Some infos from MAME.

Registers 200, 202, 204, 206, 208, 20A, 20C, 20E, 210, 211, 212, 213 (8 + 4 channels) bits [7:6] get muxed to W67.
Registers 200, 202, 204, 206, 208, 20A, 20C, 20E (8 channels) bits 5 get muxed to X84 (REVERSE).
Registers 200, 202, 204, 206, 208, 20A, 20C, 20E (8 channels) bits 4 get muxed to Z73 (DTYPE2).
Registers 200, 202, 204, 206, 208, 20A, 20C, 20E (8 channels) bits 3 get muxed to Y57 (DTYPE1).
Registers 200, 202, 204, 206, 208, 20A, 20C, 20E (8 channels) bits 2 get muxed to Y61 (DTYPE0).
Registers 200, 202, 204, 206, 208, 20A, 20C, 20E, 210, 211, 212, 213 (8 + 4 channels) bits 1 get muxed to W62.
Registers 200, 202, 204, 206, 208, 20A, 20C, 20E, 210, 211, 212, 213 (8 + 4 channels) bits 0 get muxed to X60.

CLKDIV512 ________####
CLKDIV256 ____####____
CLKDIV128 __##__##__##
CLKDIV64  _#_#_#_#_#_#
Order of reg mux: 212, 213, 200, 202, 204, 206, 208, 20A, 20C, 20E, 210, 211
So the cycle is: (212, 213, CH0, CH1, CH2, CH3, CH4, CH5, CH6, CH7, 210, 211)

CLKDIV256 ____####
CLKDIV128 __##__##
CLKDIV64  _#_#_#_#
Order of reg mux: 201, 203, 205, 207, 209, 20B, 20D, 20F
Registers 201, 203, 205, 207, 209, 20B, 20D, 20F bits 0 get muxed to Z29 (LOOPFLAG).
Registers 20F, 201, 203, 205, 207, 209, 20B, 20D bits [5:4] get muxed to MUXBIT[5:4].


* 00~FF: Eight 20-byte channel parameters
  * 00~02: Pitch
  * 03: Volume
  * 04: Reverb volume
  * 05: Pan
  * 06~07: Reverb delay
  * 08~0A: Loop position
  * 0C~0E: Start position
* 100~1FF: Effects ?
  * 13F: Analog input pan
* 200~20F: Eight 2-byte channel control
  * 00: Data type (b2-3), reverse (b5)
  * 01: Loop flag
  * Silicon: even registers use all bits
    * Test mode ? PIN_AXDA PISO can be loaded with {REG200, REG202, REG204, REG206}
  * Silicon: odd registers use bits 0, 2, 4, 5
* 210: Bits 0, 1, 6, 7 used
* 211: Bits 0, 1, 6, 7 used
* 212: Bits 0, 1, 6, 7 used
* 213: Bits 0, 1, 6, 7 used
* 214: Key on
* 215: Key off
* 216: All bits used, data, 216/218/21A/21D group
* 217: All bits used, data, 217/21E/21F/220 group
* 218: All bits used, data, 216/218/21A/21D group
* 219: All bits used, data, MULB_A[14:7]
* 21A: All bits used, data, 216/218/21A/21D group
* 21B: Counter reload value, all bits used
* 21C: Value compared against, double-buffered, all bits used
* 21D: All bits used, data, 216/218/21A/21D group
* 21E: All bits used, data, 217/21E/21F/220 group
* 21F: All bits used  data, 217/21E/21F/220 group
* 220: All bits used, data, 217/21E/21F/220 group
* 221: All bits used, data, MULB_A[14:7]
* 222: Counter reload value, all bits used
* 223: Value compared against, zero is an exception, all bits used
* 224: Bits [6:0] used
* 225: Bits 0, 1, 4, 5 used
* 226: Doesn't exist
* 227: Timer counter load value, toggles TIM output when it overflows (if enabled)
* 228: Bits [6:0] used
* 229: Bits [6:0] used
* 22A: Bits [6:0] used
* 22B: Bits [6:0] used
* 22C: Channel active flags ?
* 22D: Data r/w port (for POSTs ?)
* 22E: Bits [7:0] used, bit 7 selects ROM/RAM, bits [6:0] are top address bits for CPU access (POST), bits [16:0] come from an internal up-counter clocked by accesses to register 22D.
* 22F: General control (Enable, timer, ...)
  * Bit 0: Related to FRDL, FRDT, REDL, REDT outputs
  * Bit 1: ?
  * Bit 4: Reset internal address counter for ROM/RAM test
  * Bit 5: Low: disable TIM output (keep high), force timer counter load with value from 227
  * Bit 7: Disable internal RAM internal updates
