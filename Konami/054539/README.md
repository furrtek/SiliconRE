# Konami 054539

 * Manufacturer: Fujitsu
 * Type: Standard cell, RAM, ROM, multipliers
 * Die markings: 87821
 * Die picture: https://siliconpr0n.org/map/konami/054539...
 * Function: PCM sound
 * Used in: Racing Force, Metamorphic Force...
 * Chip donator: ?

External reverb RAM, address and data bus shared with PCM samples ROM.

# Registers

Infos from MAME.

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
  * 00: Data type, reverse
  * 01: Loop flag
* 214: Key on
* 215: Key off
* 227: Timer frequency
* 22C: Channel active flags ?
* 22D: Data r/w port (for POSTs ?)
* 22E: ROM banks / RAM select (for POSTs ?)
* 22F: General control (Enable, timer, ...)
