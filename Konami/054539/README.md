# Konami 054539

 * Manufacturer: Fujitsu
 * Type: Standard cell, RAM, ROM, multipliers
 * Die markings: 87821
 * Die picture: https://siliconpr0n.org/map/konami/054539/furrtek_mz/
 * Function: PCM sound
 * Used in:
 Pirate Ship, Polygonet, Premier Soccer, Pontoon, G.I. Joe, Lethal Enforcers, Run and Gun,
 Wild West C.O.W. boys of Moo Mesa, X-Men, Ultra Sports, Xexex, Slam Dunk, Racing Force,
 Metamorphic Force, Martial Champions, Mystic Warriors, Gaiapolis, Violent Storm, Monster Maulers, ...
 * Chip donator: Own

External reverb RAM, address and data bus shared with PCM samples ROM. Can work in pairs (only sync is offset /reset).
Can reverb RAM be shared ?

Pinout from Racing Force schematics.

Channel data in 00~FF is stored in two 128-byte odd/even RAM blocks with full read/write access. Several addresses are used for internal storage of channel state and values. Access slots are tightly interleaved (1/4) so there's no CPU access delay.
The current internal RAM access address comes from a lookup table stored in ROM A, which is read in a linear way during a 384-cycle (32 * 12) period.

Soccer Superstars, Metamorphic Force CLK = 18.43200MHz
Output rate = CLK / 384 = 48kHz

ROMA: 384 * 7 bits, data dumped from chip
ROMB: 192 * 16 bits, data dumped from chip

MULA: 8 * 16 = 24 LSB
MULB: 16 * 16 = 16 MSB

# Schematic notes

All cells are placed and connected, all pins are connected, ERC passes.

Many nets and busses aren't named or correctly named yet.

Several cells such as MUX21D, MUX41, LATCHN,... use shared differential control signals.
To reduce clutter, only the true signals are shown (the /S input on MUX21D for example is always the inverse of S).
This is why there are several inverters with unconnected outputs.

MUX41N must have their inputs in the reverse order and true/inverted control signals swapped given the order in which bus bits are connected. Couldn't know the "right" way from the start because no documentation.
Doesn't actually change anything though, so I'm leaving them as they are on the schematic.

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
Adds {0, 0, MUXB, MUXA, MUXB} (24 bits, probably pitch delta) to {MUXA, MUXA, MUXB, MUXA, MUXB} (40 bits)
Top 24 bits of {MUXA, MUXA, MUXB, MUXA, MUXB} used as address offset

ADDERB 24-bit adds channel start address or loop point (BASE[23:0]) + offset for ext address output (OFFS[23:0]).

OFFS[23:0] comes from ADDA_LAT_B[23:0] (inverted, or shifted depending on data format and reverse flag).

{RD_REG[7:0], RD_REG2[7:0]} can go to MUXD[15:0].

ADDERC 16-bit accumulates sample value with delta STEP[15:0] + {RAMA, RAMB}.

MUXD[15:0] is the sample value from ADDERC accumulator or directly from RAM: {RD_REG[7:0], RD_REG2[7:0]}.

# Sample data

MAME:
Even[3:2]=00: 8-bit PCM, end of sample marked as 0x80.
Even[3:2]=01: 16-bit PCM, end of sample marked as 0x8000.
Even[3:2]=10: 4-bit DPCM, end of sample marked as 0x88.

End of samples marked as 0x80 or 0x8000.

# Adder E

Channel mixer / accumulator ?: 10 bit (MULA_OUT[23:14]) + 24 bit (MULA_OUT[23:0])

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

Bit 0: ROMA readout.
Bit 1: MULB test.
Bit 2: ROMB readout.
Bit 3: MULA test.
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

# Effects

Reverb obviously. Maybe flanger too ? See ACCA / ACCB, which are ping-pong up/down incremental counters ticked at a programmable rate.

# Internal RAM

```
    Even    Odd
    RAMB    RAMA
00	PitchL	PitchC
01  PitchM	Vol
02	RevVol	Pan
03	RevDeL	RevDeM
04	LoopL	LoopC
05	LoopM	?
06	StartL	StartC
07	StartM	?```

Start/loop loads seem to be done from 08 09 0A 0B instead of 04 05 06 07. Maybe they're copied on channel start ?
Actually, for each channel the values in 00~0F (00~07 IRAM address) are maybe copied to 10~1F (08~0F IRAM address) to allow the sound program to update channel parameters while they are playing, and only apply them on key on.

RAMA can be written from:
* DB_IN[7:0] (CPU write)
* ADDA[39:32] frac counter
* ADDA[31:24] frac counter
* ADDA[15:8] frac counter
* MUXD[15:8] sample value
* BASE[15:8] start or loop address
* ADDD[30:23] two registers
* ADDD[14:7] two registers

RAMB can be written from:
* DB_IN[7:0] (CPU write)
* ADDA[23:16] frac counter
* ADDA[7:0] frac counter
* MUXD[7:0] sample value
* BASE[7:0] start or loop address
* BASE[23:16] start or loop address
* ADDD[22:16] two registers
* {ADDD[6:0], 0} two registers

External RAM address can come from:
* ADDB[23:0] sample data
* {AG83, ACCC[14:0], S106} reverb access ?
* {REG22E[6:0], ADDRCNT[16:0]} POST address counter

External RAM data:
* DB_IN[7:0] (CPU write)
* ACCD[7:0]
* ACCD[15:8]

* 00~FF: Eight 20-byte channel parameters
  * 00~02: Pitch
  * 03: Volume
  * 04: Reverb volume
  * 05: Pan
  * 06~07: Reverb delay
  * 08~0A: Loop position
  * 0C~0E: Start position

* 100~1FF: Effects ?
  * 13F: Analog input pan ?

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

* {217, 216}: All bits used
* {219, 218}: All bits used
* 21A: All bits used, data, MULB_A[14:7]
* 21B: LFO A update period, in CLK
* 21C: LFO A amplitude (max value)

* {21E, 21D}: All bits used
* {220, 21F}: All bits used
* 221: All bits used, data, MULB_A[14:7]
* 222: LFO B update period, in CLK
* 223: LFO B amplitude (max value)

* 224: Bits [6:0] used
  * Bit 1: Double LFO A range
  * Bit 2: Halve CNTC for period A
  * Bit 5: Double LFO B range
  * Bit 6: Halve CNTC for period B
* 225: Bits 0, 1, 4, 5 used
* 226: Doesn't exist
* 227: Timer counter load value, toggles TIM output when it overflows (if enabled)
fTIM = CLK / 256 / (255 - REG227)

* 228: Bits [6:0] used
* 229: Bits [6:0] used
* 22A: Bits [6:0] used
* 22B: Bits [6:0] used

* 22C: Channel active flags ?
* 22D: Data r/w port (for POSTs ?)
* 22E: Bits [7:0] used, bit 7 selects ROM/RAM, bits [6:0] are top address bits for CPU access (POST), bits [16:0] come from an internal up-counter clocked by accesses to register 22D.
* 22F: General control (Enable, timer, ...)
  * Bit 0: Active-low mute for all digital outputs
  * Bit 1: ?
  * Bit 4: Low: reset internal address counter for ROM/RAM test
  * Bit 5: Low: disable TIM output (keep high), force timer counter load with value from 227
  * Bit 7: Disable internal RAM internal updates

MF k054539 #1 (5F): wpset e000,400,wr
MF k054539 #2 (5E): wpset e400,400,wr

