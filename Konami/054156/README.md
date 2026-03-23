# Konami 054156

 * Manufacturer: Fujitsu
 * Type: Channeled gate array
 * Die markings: CG10572-106 2C52
 * Die picture: http://siliconpr0n.org/map/konami/054156/furrtek_mz/
 * Function: Scroll layer generator
 * Used in:
 * Chip donator: CaiusArcade
 
Evolution of the 052109. Works with the 054157 or 056832.

MAME says: 4 layers, each 64x32 or 64x64 tiles. Linescroll and banking on each.

12-bit tile code, 2-bit tile bank, X/Y flip.

CPU VRAM access is 8-bit only.

# VRAM data

3 or 2 bytes per tile

* [23:16]: Attributes (x/y flip bits selected by REG6[7:6]
* [15:13]: Tile code bank number (looked up to 6 bits)
* [12:0]: Tile code lower bits

# Registers

Some infos from MAME, discoveries and details added:

00[7:0]: ??yx ????, all bits used
* 7: VRAM/VROM ?
* 6: Dot clock select ?
* 5: Enable full display vertical flip
* 4: Enable full display horizontal flip
* 3: ?
* 2: Video timing gen select
* 1: Linescroll RAM present ?
* 0: Number of layers 2/4 0:2 1:4

02[7:0]: ???? ????, all bits used, X/Y tile flip enable for each layer ?
* 0,2,4,6: Enable tile X flips
* 1,3,5,7: Enable tile Y flips

04[7:0]: -??- ????, bits 4 and 7 unused
[7:6]: ?
* 3: Select address mode for registers 0:AB[13:3] 1:AB[12:2]
* 2: 0:LU[1:0], 1:Use VRAM attribute directly [7:6]
* 1: 0:LU[1:0], 1:Use VRAM attribute directly [1:0]
* 0: 0:LU[1:0], 1:Use VRAM attribute directly [3:2]

06[7:0]: ???? ???e, all bits used, enable IRQ
* [7:6]: Choice of bits in VRAM attribute for X/Y tile flip
* 5: 1=8-bit register access, 0=16-bit
* 4: VRAM attributes 16/24 bits
* 3: ?
* 2: NMI enable (16 lines ?)
* 1: FIRQ enable (2 lines ?)
* 0: IRQ enable (v-blank ?)

08[7:0]: ???? ????, all bits used
* [7:4]: Related to how long the Y scroll value for each layer is presented to V adder
* [3:0]: Related to tile size ?

0A[7:0]: 3322 1100, all bits used, linescroll mode for each layer. 0: per line, 2: 8 lines, 1/3: no linescroll.
x1: Use registers 28/2A/2C/2E
* [1:0]: reg 28
* [3:2]: reg 2A
* [5:4]: reg 2C
* [7:6]: reg 2E

0C[5:0]: --?? ????
* [5:2]: Something for each layer ?
* [1:0]: VRAM configuration

Reg 0E doesn't exist

10~13[7:0]: ??yyyhhh, layer Y position in VRAM grid, height in pages

17~1F[7:0]: ??xxxwww, layer X position in VRAM grid, width in pages

20~27[10:0]: Scroll Y for each layer

28~2F[11:0]: Scroll X for each layer

30[5:0]: Linescroll VRAM bank select
Ends up on PIN_VA[16:11]

32[5:0]: CPU access VRAM bank select
Ends up on PIN_VA[16:11]

34[15:0]: ROM bank select for CPU readout (each is 0x2000)
Ends up on {PIN_COL[7:0], PIN_CA[18:11]}

36[1:0]: top of ROM bank select for CPU readout when tile banking used
Ends up on PIN_VRC[1:0]

38[15:0]: 3333 2222 1111 0000, tile banking lookup. 4 bits looked up here for the two bits in the tile data

3A[11:0]: X offset when horizontal flip enabled by REG0[4].

3C[10:0]: Y offset when vertical flip enabled by REG0[5].

# Linescroll

Data starts in VRAM bank set by register 30, data for each layer is 400 or 800 depending on VRAM bank size. When enabled, layer X scroll setting is ignored.
