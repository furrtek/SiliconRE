# Konami 054157

 * Manufacturer: Fujitsu
 * Type: Channeled gate array
 * Die markings: CG10572-107 2C52
 * Die picture: http://siliconpr0n.org/map/konami/054157/furrtek_mz/
 * Function: Scroll layer data combiner
 * Used in:
 * Chip donator: rep-arcade.com
 
Evolution of the 051962. Works with the 054156.

# Registers

Some infos from MAME, discoveries and details added:

00[7:0]: Some bits shared with 054156
* 4: Enable full display horizontal flip
* 3: ?
* 0: Number of layers 2/4 0:2 1:4

02[7:0]: Some bits shared with 054156
* 0,2,4,6: Enable tile X flips

04[7:0]: Some bits shared with 054156
* [6:4]: ?
* 3: Select 8/16bit mode ?

06[7:0]: ???? ???e, all bits used, enable IRQ
* [7:6]: Choice of bits in VRAM attribute for X/Y tile flip
* 5: 1=8-bit ROM access, 0=16-bit
