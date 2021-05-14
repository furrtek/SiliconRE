# Konami 007121

# Nets without drivers - best guesses

* DCLK13=NN222 - Wrong merged nets at c256 ?
* DCLK16=DCLK18=RR218 at k249 ?
* COM2=AA186 ?
* COM4=PP182 ?
* COM7=NN196 ?
* COM10=Z245 ?
* N2=V216 ?
* N5=N7=J229 ?
* N6=H220 ?
* N8=BB243 ?
* N28=A226 ?
* ND5=V195=SPR_WIDTH_8 ?
* ND32=FF226 ?
* RES2=V108 ?
* RES4=RES1 ?
* RES5=V64 ?
* RES6=RES11=RES12=MM132 ?
* RES7
* RES10
* CLK6=$H2_BUF ?
* CLK8=$CK24_1 ?

# Pins

See file 007121.ods

# Registers

`Unused` means that there's no latch for the given bit of the given register, writing to it does nothing.

* Register 0: X scroll value, lower 8 bits
* Register 1:
  * Bit 7: Forces pin NRM low (which pin is NRM?)
  * Bit 6~4: Unused
  * Bit 3: Select text mode when high. Layout related
  * Bit 2: 0=Row scrolling, 1=Column scrolling
  * Bit 1: Enable row/column scrolling
  * Bit 0: X scroll value, higher bit
* Register 2: Y scroll value
* Register 3:
  * Bit 7: Unused
  * Bit 6: Blanking related. According to MAME, the effect is to
           removed the leftmost and rightmost columns of the image
  * Bit 5: Priority related, selects between S7 or P8
  * Bit 4: Selects text mode when low. Layout related
  * Bit 3: Highest VRAM address bit when parsing sprite list ($0000/$8000)
  * Bit 2: Priority related, opaque sprite pixels have highest priority
  * Bit 1: Unused
  * Bit 0: Highest gfx ROM address bit for scroll layer tile fetches (tile code bit 13, pin R17)
* Register 4:
  * Bit 7: Scroll layer tile code bit 12, 0=From data selected by register 5, 1=Directly from register 4 bit 3
  * Bit 6: Scroll layer tile code bit 11, 0=From data selected by register 5, 1=Directly from register 4 bit 2
  * Bit 5: Scroll layer tile code bit 10, 0=From data selected by register 5, 1=Directly from register 4 bit 1
  * Bit 4: Scroll layer tile code bit 9, 0=From data selected by register 5, 1=Directly from register 4 bit 0
  * Bit 3~0: Scroll layer tile code bits 12:9, selected individually by the above bits
* Register 5:
  * Bit 7~6: Scroll layer tile code bit 12 comes from VRAM attribute bit 00=3, 01=4, 10=5 or 11=6
  * Bit 5~4: Scroll layer tile code bit 11 comes from VRAM attribute bit 00=3, 01=4, 10=5 or 11=6
  * Bit 3~2: Scroll layer tile code bit 10 comes from VRAM attribute bit 00=3, 01=4, 10=5 or 11=6
  * Bit 1~0: Scroll layer tile code bit 9 comes from VRAM attribute bit 00=3, 01=4, 10=5 or 11=6
* Register 6:
  * Bit 7~6: Unused
  * Bit 5: Final color output bit 6 (pin COA6)
  * Bit 4: Final color output bit 5 (pin COA5)
  * Bit 3: Enable bit 6 of scroll layer tile attribute as priority flag
  * Bit 2: Enable bit 5 of scroll layer tile attribute as Y flip flag
  * Bit 1: Enable bit 4 of scroll layer tile attribute as inversion of lowest gfx ROM address bit for scroll layer tile fetches (X flip flag ?)
  * Bit 0: Enable bit 3 of scroll layer tile attribute as highest color lookup address (pin VCB3)
* Register 7:
  * Bit 7~5: Unused
  * Bit 4: Select NMI repetition rate 0=16 scanlines, 1=32 scanlines
  * Bit 3: Flip display in both X and Y
  * Bit 2: Enable FIRQs
  * Bit 1: Enable IRQs
  * Bit 0: Enable NMIs

# Priority

Scroll / sprite priority is decided on pages "PRIORITY" and "COLOR OUTPUT".
The tile's priority bit is the tilemap's attribute bit 6 when reg 6 bit 3 is high, otherwise it is set to 0.
It's loaded in the same kind of 8-bit shift register used for the tile's pixels, so once loaded it stays the same for a given 8-pixel row.
The output of the shift register is finally used only if reg 3 bits 2 and 5 are set.
If the priority bit is set, and the current pixel is opaque (color isn't zero), then opaque scroll pixels have priority.

If reg 3 bit 2 is set, bit 5 is reset, and P6 (wrong ? doesn't make sense) is high, then all scroll pixels have priority ?

If reg 3 bit 2 is reset, then both scroll and sprite priority bits are unused. Opaque sprite pixels are given priority.

# Color output

Pins COA0-COA3 represent the final 4bpp pixel. COA4 indicates 0=Sprite pixel, 1=Scroll pixel. COA5 and COA6 are set by reg 6 bits 4 and 5.
During blanking, only COA0-COA3 are set to 0. COA4-COA6 continue functioning like in the active display.
When pin NWCS is low, the CPU address bus A1-A7 are routed to pins COA0-COA6. This has priority over blanking.

COA bit | Meaning
--------|--------------------------
6       | set by register 6, bit 5
5       | set by register 6, bit 4
4       | 0=sprite 1=scroll
3:0     | Final pixel color

# Line buffers

GFX ROM data bus is 16 bit wide = 4 * 4bpp pixels.

Sprite pixels are written to DRAM 2 by 2 (2 * 4bpp), they're also read out 2 by 2 and split in turn to go into the priority circuit.

# Scroll RAM

May be used for row or column scrolling. A row or column is 8 pixels.

* Row scrolling: register 0 (X scroll) is overridden.
* Column scrolling: register 2 (Y scroll) is overridden.

It is not a regular RAM block, but 288 latches to store 32 9-bit values (only 8 bits used for column scrolling).

The latch data input comes from a 2-to-1 mux to either store a new value written by the CPU, or the value from SCROLL_OUTx (to keep the previous one)

Memory mapping:
* 20:3F = lower 8 bits
* 40:5F = highest bit in b0

x01x xxxx = low
x10x xxxx = high

A6 selects low 8 bits/highest bit
0x00 0000

Reading:
If below $2000, read scroll RAM

# Sprite attributes

* Byte 0:
  * Bit 7: SPR_CODE7
  * Bit 6: SPR_CODE6
  * Bit 5: SPR_CODE5
  * Bit 4: SPR_CODE4
  * Bit 3: SPR_CODE3
  * Bit 2: SPR_CODE2
  * Bit 1: If SPR_SIZE2=0: SPR_CODE1, =1(32*32):Ignored, SPR_CODE1=COUNTER1_Q2
  * Bit 0: If SPR_SIZE2=0: SPR_CODE0, =1(32*32):Ignored, SPR_CODE0=EE114
* Byte 1:
  * Bit 7~4: Palette number
  * Bit 3: SPR_CODE_LOW1
  * Bit 2: SPR_CODE_LOW0
  * Bit 1: SPR_BANK1
  * Bit 0: SPR_BANK0
* Byte 2: Y position, reload value for COUNTER9 and COUNTER12
* Byte 3:
  * Bit 7~1: X position lower bits, reload value for COUNTER6 and COUNTER13
  * Bit 0: Used as odd/even pixel selection for writing in line buffers
* Byte 4:
  * Bit 7: SPR_BANK3
  * Bit 6: SPR_BANK2
  * Bit 5: SPR_FLIPY
  * Bit 4: SPR_FLIPX
  * Bit 3: SPR_SIZE2
  * Bit 2: SPR_SIZE1
  * Bit 1: SPR_SIZE0
  * Bit 0: X position highest bit, COUNTER6_D3

# Sprite layout

* SPR_SIZE2: Size is 32*32
* SPR_SIEZ1: Width is 0=16px, 1=8px
* SPR_SIEZ0: Height is 0=16px, 1=8px

| SPR_SIZE | Width | Height | Notes | GFX ROM address, x means bit kept (LOW0/LOW1), 0 means replaced by internal counter
|----------|-------|--------|---------------------------------------------------------------|-------------------|
| 000      | 16    | 16     | SPR_HEIGHT_8=0, COUNTER1 reloaded with 1, 1, ~Z58, ~Z58       | A131, AA76, SPR_CODE0... MAME:xx00 ok
| 001      | 16    | 8      | SPR_HEIGHT_8=1, COUNTER1 reloaded with 1, 1, 1, ~Z58          | A131, LOW1, SPR_CODE0... MAME:xxx0 ok
| 010      | 8     | 16     | SPR_HEIGHT_8=0, COUNTER1 reloaded with 1, 1, 1, ~Z58          | LOW0, A93, SPR_CODE0...  MAME:xx0x ok
| 011      | 8     | 8      | SPR_HEIGHT_8=1, COUNTER1 reloaded with 1, 1, 1, 1             | LOW0, LOW1, SPR_CODE0... MAME:xxxx ok
| 100      | 32    | 32     | SPR_HEIGHT_8=0, COUNTER1 reloaded with ~Z58, ~Z58, ~Z58, ~Z58 | A131, C93, SPR_CODE0...  MAME:xx00 ok

COUNTER1 is enabled only when size=011 ? Doesn't make sense.

Sprite tile mapping:

8x8:
0

8x16:
0
2?

16x8:
01

16x16:
01
23

32x32:
0145
2367
89CD
ABEF

D121 =  COUNTER8_Q2 (H2) ^ SPR_FLIPX (selects left/right 4-pixel group of the 8-pixel line)
A131 =  COUNTER8_Q3 (H3) ^ (SPR_WIDTH_8 =0:SPR_FLIPY =1:SPR_FLIPX)
EE114 = COUNTER5_Q0 (H4) ^ (SPR_SIZE2 =0:SPR_FLIPY =1:SPR_FLIPX)
CC120 = COUNTER5_Q1 (H5) ^ SPR_FLIPY
A93 =   COUNTER1_Q0 ^ SPR_FLIPY
AA76 =  COUNTER1_Q1 ^ SPR_FLIPY
C93 =   COUNTER1_Q2 ^ SPR_FLIPY

# GFX ROM address

| Pin | SCROLL             | SPR                        | 8x8  | 8x16 | 16x8 | 16x16 | 32x32 |
|-----|--------------------|----------------------------|------|------|------|-------|-------|
| R0  | COUNTER8Q1/ATTR4   | D121                       | D121 |      |      |       |       |
| R1  |                    | SPR_SIZE2=0:T119, =1:CC120 | A131 | A131 | EE114| EE114 | CC120 | Tile line A0
| R2  |                    | SPR_SIZE2=0:W128, =1:A93   | EE114| EE114| CC120| CC120 | A93   | Tile line A1
| R3  |                    | SPR_SIZE2=0:V123, =1:AA76  | CC120| CC120| A93  | A93   | AA76  | Tile line A2
| R4  | Code bit 0         | T131                       | LOW0 | LOW0 | A131 | A131  | A131
| R5  | Code bit 1         | SPR_SIZE2=0:X122, =1:C93   | LOW1 | A93  | LOW1 | AA76  | C93
| R6  | Code bit 2         | SPR_CODE0
| R7  | Code bit 3         | SPR_CODE1
| R8  | Code bit 4         | SPR_CODE2
| R9  | Code bit 5         | SPR_CODE3
| R10 | Code bit 6         | SPR_CODE4
| R11 | Code bit 7         | SPR_CODE5
| R12 | Attribute bit 7    | SPR_CODE6
| R13 | See reg 4 and 5    | SPR_CODE7
| R14 | See reg 4 and 5    | SPR_BANK0
| R15 | See reg 4 and 5    | SPR_BANK1
| R16 | See reg 4 and 5    | SPR_BANK2
| R17 | Reg 3 bit 0        | SPR_BANK3

T119:
|SPR_HEIGHT_8 | SPR_WIDTH_8 | Output|
|-------------|-------------|-------|
|0            | 0     | EE114
|0            | 1     | A131
|1            | 0     | EE114
|1            | 1     | A131

W128:
|SPR_HEIGHT_8 | SPR_WIDTH_8 | Output|
|-------------|-------------|-------|
0            | 0     | CC120
0            | 1     | EE114
1            | 0     | CC120
1            | 1     | EE114

V123:
|SPR_HEIGHT_8 | SPR_WIDTH_8 | Output|
|-------------|-------------|-------|
0            | 0     | A93
0            | 1     | CC120
1            | 0     | A93
1            | 1     | CC120

T131:
|SPR_HEIGHT_8 | SPR_WIDTH_8 | Output|
|-------------|-------------|-------|
0            | 0     | A131
0            | 1     | SPR_CODE_LOW0
1            | 0     | A131
1            | 1     | SPR_CODE_LOW0

X122:
|SPR_HEIGHT_8 | SPR_WIDTH_8 | Output|
|-------------|-------------|-------|
0            | 0     | AA76
0            | 1     | A93
1            | 0     | SPR_CODE_LOW1
1            | 1     | SPR_CODE_LOW1

Tilemap is made of pairs of code-attribute bytes for each tile ?
