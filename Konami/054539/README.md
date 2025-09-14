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

Pinout from Racing Force schematics.

TODO: Check DFFSQs, they're probably DFFRQs (the /set is behind the output inverter).

Channel data in 00~FF is actually stored in two 128-byte RAM blocks. There might be a CPU access delay involved.
Sequencing is done with the help of ROM A, which is used to set the channel data RAM address given the current state.

There's a bidirectional path between DB[7:0] and RD[7:0].
There's a path from RAM_A_DOUT[7:0] to DB[7:0].
There's a path from RAM_B_DOUT[7:0] to DB[7:0].

There's a path from DB[7:0] to RAM_A_DIN[7:0].
There's a path from DB[7:0] to RAM_B_DIN[7:0].

There's a path from ROMA_D[6:0] to RA[6:0].
There's a path from ROMB_D[15:0] to RA[15:0].

There's a path from RD[7:0] to MULA_A[7:0].
There's a path from DB[7:0] to MULA_B[7:0].
There's a path from AB[7:0] to MULA_B[15:8].
There's a path from MULA_OUT[15:0] to RA[15:0].

There's a path from RD[7:0] to MULB_A[7:0].
There's a path from {AXXA, AXDA, ALRA, AXWA, RRMD, USE2, DTS2, DTS1} to MULB_A[15:8].
There's a path from DB[7:0] to MULB_B[7:0].
There's a path from AB[7:0] to MULB_B[15:8].
There's a path from MULB_OUT[23:0] to RA[23:0].

Samplerate: Racing Force TOPCK = 18MHz

ROMA: 384 * 7 bits
ROMB: 192 * 16 bits

MULA: 8->16 * 16 = 24
MULB: 16 * 16 = 16

# Test register

Two 8-bit test registers set to DB[7:0] by posedge on TS1 and TS2 pins. Both are cleared on reset.

## TESTREG1

Bit 0: Forces S109 = S121 = 1.
Bit 1: Forces S109 = S121 = 1.
Bit 2: Forces S109 = S121 = 1.
Bit 3: Forces S109 = S121 = 1.
Bit 4: Forces S109 = S121 = 1.
Bit 5: Forces S109 = S121 = 1.
Bit 6: Uses pins RRMD, ADDA, and USE2 as alternate inputs for ?.
Bit 7: Selects source for ROMA_A8.

## TESTREG2

Bit 0: selects MUX_A_D[7:0] source: RAM_A_DOUT[7:0] or RD[7:0].
Bit 1: selects TIMER clock source. Forces S109 = S121 = 1.
Bit 2: Forces S109 = S121 = 1.
Bit 3: T95, N73 select.
Bit 4: Forces S109 = S121 = 1.


# Registers

Some infos from MAME.

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
* 22E: Bits [6:0] used, ROM bank / RAM select (for POSTs ?)
* 22F: General control (Enable, timer, ...)
  * Bit 0: ?
  * Bit 1: ?
  * Bit 4: ?
  * Bit 5: Low: disable TIM output (keep high), force timer counter load with value from 227
