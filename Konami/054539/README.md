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

TODO: The DFFSNNQ are really DFFRNNQ (the /set is behind the output inverter).

Channel data in 00~FF is actually stored in two 128-byte RAM blocks. There might be a CPU access delay involved.
Sequencing is done with the help of ROM A, which is used to set the channel data RAM address given the current state.

There's a bidirectional path between DB[7:0] and RD[7:0].
There's a path from RAM_A[7:0] to DB[7:0].
There's a path from RAM_B[7:0] to DB[7:0].

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
  * Silicon: odd registers use bits 0, 2, 4, 5
* 210: Bits 0, 1, 6, 7 used
* 211: Bits 0, 1, 6, 7 used
* 212: Bits 0, 1, 6, 7 used
* 213: Bits 0, 1, 6, 7 used
* 214: Key on
* 215: Key off
* 216: All bits used
* 217: All bits used, data
* 218: All bits used, data
* 219: All bits used
* 21A: All bits used
* 21B: Counter reload value, all bits used
* 21C: All bits used
* 21D: All bits used
* 21E: All bits used, data
* 21F: All bits used
* 220: All bits used, data
* 221: All bits used
* 222: Counter reload value, all bits used
* 223: Exists
* 224: All bits used
* 225: Exists
* 226: Doesn't exist
* 227: Timer counter load value, toggles TIM output when it overflows (if enabled)
* 228: Exists
* 229: Bits [6:0] used
* 22A: Exists
* 22B: Bits [6:0] used
* 22C: Channel active flags ?
* 22D: Data r/w port (for POSTs ?)
* 22E: ROM banks / RAM select (for POSTs ?)
* 22F: General control (Enable, timer, ...)
  * Bit 0: ?
  * Bit 1: ?
  * Bit 4: ?
  * Bit 5: Low: disable TIM output (keep high), force timer counter load with value from 227
