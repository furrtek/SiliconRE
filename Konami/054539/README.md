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
 * Chip donator: ?

External reverb RAM, address and data bus shared with PCM samples ROM.

Schematics: Racing Force

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
  * Silicon: odd registers use bits 2, 4, 5, ?
  * Silicon: even registers use all bits
* 210: ?
* 211: ?
* 212: ?
* 213: ?
* 214: Key on
* 215: Key off
* 216: ?
* 217: All bits used
* 218: ?
* 219: ?
* 21A: ?
* 21B: ?
* 21C: ?
* 21D: ?
* 21E: ?
* 21F: ?
* 220: ?
* 221: ?
* 222: ?
* 223: x
* 224: ?
* 225: ?
* 226: x
* 227: Timer counter load value, toggles TIM output when it overflows (if enabled)
* 228: ?
* 229: ?
* 22A: ?
* 22B: ?
* 22C: Channel active flags ?
* 22D: Data r/w port (for POSTs ?)
* 22E: ROM banks / RAM select (for POSTs ?)
* 22F: General control (Enable, timer, ...)
  * Bit 1: ?
  * Bit 5: Disable TIM output (keep high), force timer counter load with value from 227

ROM A data sets both RAM blocks address.
