# Konami 054338

 * Manufacturer: Fujitsu
 * Type: Channeled gate array
 * Die markings: CG10572-113
 * Die picture: Unavailable
 * Function: Alpha blending
 * Used in: Bucky 'O Hare, Cowboys of Moo Mesa, Martial Champion, Violent Storm, XEXEX
 * Chip donator: @CaiusArcade

# Registers

Word-wise

* 0: [7:0] only, [15:8] don't exist. Background red.
* 1: [15:8] background green, [7:0] background blue.
* 2: [15:0] shadow 1 RGB
* 3: [15:0]
* 4: [15:0]
* 5: [15:0] shadow 2 RGB
* 6: [15:0]
* 7: [15:0]

* 8: [15:0] shadow 3 RGB
* 9: [15:0]
* 10: [15:0]
* 11: [7:0] only, [15:8] don't exist. Brightness RGB (external DAC current set ?)
* 12: [15:0]
* 13: [7:0] only, [15:8] don't exist. Alpha blend RGB
* 14: [15:0]
* 15: [5:0] only. Configuration.
[0]: 1 enables layers, 0 forces background color
[1]: Select MIX pins input delay
[2]: Select SHD pins input delay
[3]: Select BRI pins input delay
[4]: ?
[5]: Something to do with min/max clamping
