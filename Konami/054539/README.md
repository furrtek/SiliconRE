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

# Blocks

**Adder A** is used for adding each channel's base address and the 40-bit fractional accumulator (sample ROM address offset from channel pitch parameter). When the end of the sample stream is reached, if the loop bit is set, the base address is replaced by the contents of the channel loop address and the upper 24 bits of the fractional accumulator are reset to zero.

The channel pitch parameter (24 bits) is added to the channel's fractional accumulator value (40 bits) and stored back. If the channel is not enabled, the added pitch is forced to zero, so the addition keeps the original _frac_ value.

The top 24 bits of _frac_ are used for the sample ROM address offset, after shifting depending on the channel's data type parameter. For 4-bit delta PCM, the address is shifted to the right, whereas for 16-bit samples the address is shifted to the left.

| ADDA Bits | Address | RAM  |
|-----------|---------|------|
| 39:32	    |  0x0f   | RAMA |
| 31:24	    |  0x11   | RAMA |
| 23:16	    |  0x10   | RAMB |
| 15:8	    |  0x13   | RAMA |
| 7:0	      |  0x12   | RAMB |

The fractional counter is reset when:

1. The channel is turned off via the _key off_ register 0x215
2. The

**Adder B** is 24-bit, it adds the channel's start address or loop point (BASE[23:0]) + offset for ext address output (OFFS[23:0]).

**Adder C** 16-bit accumulates the sample value with delta STEP[15:0] + {RAMA, RAMB} if channel data type is set to DPCM.

**Adder D** 31 + 31 = 31.

**Adder E** is a two-step adder that uses channel RAM #3 parameter one byte after the other. (MULA_PREV << 7) + MULA[23:7], outputs 31 bits.

# Key on/off behavior

When a write to register 0x214 occurs, the input data byte signals which channels will go active. Channels become active at the start of the next sequence. When the next sequence starts, the fractional register gets reset to zero.

A write to register 0x215 stops the given channel immediately, without waiting to the next sequence start.

When playback starts, the _start address_ registers are used for the base until the first time the EOF marker is reached. Then the loop address registers are read. When EOF is reached, if the channel loop enable bit is low, then the channel goes off.

A key on event (write to 0x214) while the channel is active restarts the fractional counter

# Sample data

MAME:
Even[3:2]=00: 8-bit PCM, end of sample marked as 0x80.
Even[3:2]=01: 16-bit PCM, end of sample marked as 0x8000.
Even[3:2]=10: 4-bit DPCM, end of sample marked as 0x88.

# Output mixer

Three pairs of 16 bit registers (MULB_OUT[15:0] + REGEA/B/C/D/E/F)
Three final outputs * 2 channels ?
REGED ends up in the FRDL PISO
REGEB ends up in the FRDT PISO
REGEC ends up in the REDL PISO
REGEA ends up in the REDT PISO
REGEE and REGEF end up in the final output PISO

Each of the 6 REGE's are updated 12 times per cycle (8 + 4 channels ?)

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

# Effects

Reverb obviously. Maybe flanger too ? See LFOA / LFOB, which are ping-pong up/down counters ticked at a programmable rate.

# Internal RAM

|    | Even (RAMB) | Odd (RAMA)  |
|----|-------------|-------------|
| 00 | PitchLSB    | PitchMid    |
| 01 | PitchMSB    | ChVol       |
| 02 | RevVol      | Pan         |
| 03 | RevDelay    | RevDelay    |
| 04 | LoopLSB     | LoopMid     |
| 05 | LoopMSB     |    -        |
| 06 | StartLSB    | StartC      |
| 07 | StartM      | FracMSB     |
| 08 | FracMid     | FracMid     |
| 09 | FracLSB     | FracLSB     |
| 0A | PrevSample  | PrevSample  |
| 0B | Feedback?   | Feedback?   |
| 0C | Feedback?   | Feedback?   |
| 0D | Feedback?   | Feedback?   |
| 0E | Feedback?   | Feedback?   |
| 0F |    -        |     -       |

RevDelay isn't used for ext RAM address, but for MULA input. So probably volume setting rather than delay.

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

External address can be:
* ROM address
* RAM address
* POST address counter
* Test mode data output

# Channel data type

Set by even registers 200~20E bits [4:2].
* 0: direct address offset	RD_REGB=0	8-bit PCM sample
* 1: address offset << 1				16-bit PCM sample
* 2: address offset >> 1	RD_REGB=0	4-bit DPCM	STEP = {DPCM_STEP[7:0], 8'd0} (max step size)
* 3: address offset << 1    *						STEP = {DPCM_STEP[7:0], 8'd0} (max step size)
* 4: address offset >> 1	RD_REGB=0	4-bit DPCM 	STEP = {DPCM_STEP[7]x4, DPCM_STEP[7:0], 4'd0} (max step size >> 4)
* 5: address offset << 1	*						STEP = {DPCM_STEP[7]x4, DPCM_STEP[7:0], 4'd0} (max step size >> 4)
* 6: address offset >> 1	RD_REGB=0	4-bit DPCM 	STEP = {DPCM_STEP[7]x8, DPCM_STEP[7:0]} (max step size >> 8)
* 7: address offset << 1	*						STEP = {DPCM_STEP[7]x8, DPCM_STEP[7:0]} (max step size >> 8)

The different DPCM step size settings are maybe to allow compromises between noise floor and frequency response ? Larger steps = higher noise but better high frequencies.

* 4-bit DPCM in 16-bit values ? What's the point ? Maybe those aren't meant to be used.

# Stereo Panning

The pan register for each channel contains independent volume information for the left and right speakers.

| Bits     | Use          |
|----------|--------------|
| 7:4      | Right volume |
| 3:0      | Left volume  |

There are two look-up tables in ROMB starting at address 192. Each 4-bit pan value is used to read one of the tables. The two tables contain the same values but are upside down for entries 1-15. Entry 0 is always zero.

The panning value is a 16-bit width and goes into multiplier B.

Bit 1 of the control register $22F can be set in order to disable panning and have the same gain for both channels.

# Auxiliary Input

The auxiliary input is used to mix the sound from an external source. It can take either a stereo 16-bit signal, or decode Yamaha's mantissa/exponent format. The pin **YMD** selects the data format. The volume for the auxiliary input is set by one of registers $228,$229,$22A and $22B. Which register is used is set by bits 1:0 of registers $210 (left) and $211 (right).

*To do* confirm that it is not $210 (right) and $211 (left) instead.

# Registers

Some infos from MAME.

Register addresses assume {A[9], A[7:0]} are used, not A[8] (nothing in 100~1FF).

* 00~FF: Eight 32-byte channel parameters, these go into internal RAM. Values 0F~1F used for internal stuff but should be R/Wable by CPU like the rest.
  * 00~02: Pitch
  * 03: Volume
  * 04: Reverb volume (silicon: top/bottom nibbles used separately)
  * 05: Pan (silicon: top/bottom nibbles used separately)
  * 06~07: Reverb delay ? (used as MULA A)
  * 08~0A: Loop position
  * 0C~0E: Start position

* 200~20F: Eight 2-byte channel control, these are dedicated registers.
  * 00: Data type (b2-3), reverse (b5)
  * 01: Loop flag (b0)
  * Silicon: even registers use all bits, [1:0] select which of registers 228/229/22A/22B to use for volume ?, [4] part of data type, [7:6] are related to panning (top bit of ROMB panning tables address)
    * Test mode ? PIN_AXDA PISO can be loaded with {REG200, REG202, REG204, REG206}
  * Silicon: odd registers use bits 0, 2, 4, 5

* 210: Bits 0, 1, 6, 7 used, same as even registers 200~20E (see above)
* 211: Bits 0, 1, 6, 7 used, same as even registers 200~20E (see above)
* 212: Bits 0, 1, 6, 7 used, same as even registers 200~20E (see above)
* 213: Bits 0, 1, 6, 7 used, same as even registers 200~20E (see above)

* 214: Key on
* 215: Key off

* {217, 216}: All bits used, RAM related
* {219, 218}: All bits used, RAM related
* 21A: All bits used, data, MULB_A[14:7]
* 21B: LFO A update period, in CLK
* 21C: LFO A amplitude (max value)

* {21E, 21D}: All bits used, RAM related
* {220, 21F}: All bits used, RAM related
* 221: All bits used, data, MULB_A[14:7]
* 222: LFO B update period, in CLK
* 223: LFO B amplitude (max value)

* 224: Bits [6:0] used
  * Bit 0: Used with bit 4, selects which of REGEEB or REGEFB is stored in ext RAM
  * Bit 1: Double LFO A range
  * Bit 2: Halve CNTC for period A
  * Bit 3: Enable effects ?
  * Bit 4: See bit 0
  * Bit 5: Double LFO B range
  * Bit 6: Halve CNTC for period B
* 225: Bits 0, 1, 4, 5 used
  * Bits 0, 1: Selects MUXH
  * Bits 4, 5: Selects AG83 source when 224[3] set
* 226: Doesn't exist
* 227: Timer counter load value, toggles TIM output when it overflows (if enabled)
fTIM = CLK / 256 / (255 - REG227)

* 228: Bits [6:0] used, ROMB address, volume setting
* 229: Bits [6:0] used, ROMB address, volume setting
* 22A: Bits [6:0] used, ROMB address, volume setting
* 22B: Bits [6:0] used, ROMB address, volume setting

* 22C: Channel active flags ?
* 22D: Data r/w port for external memory
* 22E: Bits [7:0] used, bit 7 selects ROM/RAM, bits [6:0] are top address bits for CPU access (POST), bits [16:0] come from an internal up-counter clocked by accesses to register 22D.
* 22F: General control (Enable, timer, ...)
  * Bit 0: Active-low mute for all digital outputs
  * Bit 1: Disables panning
  * Bit 4: Low: reset internal address counter for ROM/RAM test
  * Bit 5: Low: disable TIM output (keep high), force timer counter load with value from 227
  * Bit 7: Disable internal RAM internal updates

MF k054539 #1 (5F): wpset e000,400,wr
MF k054539 #2 (5E): wpset e400,400,wr

