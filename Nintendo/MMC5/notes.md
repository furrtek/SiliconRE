# Nintendo MMC5

NEC CMOS 1-metal standard cell custom chip with dedicated blocks, some analog. Internal ID: D6319

Multi-purpose NES/Famicom mapper with embedded SRAM, 8x8 multiplier, PPU extensions, audio and analog functions.

Used on a few late games.

# Pinout

* PRG_RAM_A[16:13], 8kB bank granularity, max 16
* PRG_ROM_A[19:13], 8kB bank granularity, max 128
* CHR_ROM_A[19:10], 1kB bank granularity, max 1024 (split as 2 common high bits + 8)
* CHR_ROM_A[2:0], for tile vertical scrolling when PPU reads $0000~0FFF ?

# Address decodes

* $2000: K87	W	PPUCTRL mirror
* $2001: K91	W	PPUMASK mirror
* $2002: K92	R	PPUSTATUS
* $2005: K93	W	PPUSCROLL mirror
* $2006: 		W	PPUADDR mirror (MMC5A only ?)

* $4014: K94	W	OAMDMA mirror

* $5000: K8		W	Pulse 1
* $5002: K11	W	Pulse 1
* $5003: K14	W	Pulse 1
* $5004: K71	W	Pulse 2
* $5006: K75	W	Pulse 2
* $5007: K78	W	Pulse 2
* $5010: K17	R/W	PCM mode
* $5011: K19	W	PCM data
* $5015: K97	R/W	Audio status

* $5100: K20	W	PRG mode
* $5101: K21	W	CHR mode
* $5102: K22	W	PRG RAM protect 1
* $5103: K26	W	PRG RAM protect 2
* $5104: K28	W	Internal RAM mode
* $5105: K29	W	Nametable mapping
* $5106: K31	W	Fill mode tile
* $5107: K32	W	Fill mode color

* $5113: K33	W	PRG bank
* $5114: K35	W	PRG bank
* $5115: K38	W	PRG bank
* $5116: K40	W	PRG bank
* $5117: K41	W	PRG bank

* $5120: K42	W	CHR bank
* $5121: K43	W	CHR bank
* $5122: K45	W	CHR bank
* $5123: K46	W	CHR bank
* $5124: K49	W	CHR bank
* $5125: K50	W	CHR bank
* $5126: K52	W	CHR bank
* $5127: K54	W	CHR bank
* $5128: K81	W	CHR bank
* $5129: K83?	W	CHR bank
* $512A: K85?	W	CHR bank
* $512B: K86?	W	CHR bank
* $5130: K56	W	CHR bank upper bits

* $5200: K58	W	Vertical split mode
* $5201: K60	W	Vertical split scroll
* $5202: K64	W	Vertical split bank

* $5203: K65	W	Scanline IRQ compare
* $5204: K66	R/W	Scanline IRQ status

* $5205: K67	R/W	Multiplier low
* $5206: K69	R/W	Multiplier high

* $5C00~5FFF: 	R/W	Internal RAM

# To be expected

Infos deducted from nesdev.org

```
PRG ranges:
Range			Mode		Description
$6000~7FFF		All 		8kB RAM bank
$8000~FFFF		0 			32kB ROM bank
 $8000~BFFF		1, 2		16kB ROM/RAM bank
  $8000~9FFF	3           8kB ROM/RAM bank
  $A000~BFFF	3           8kB ROM/RAM bank
 $C000~FFFF		1 			16kB ROM bank
  $C000~DFFF	2, 3		8kB ROM/RAM bank
  $E000~FFFF	2, 3		8kB ROM bank

CHR ranges:
$0000~1FFF		0			8kB CHR bank
 $0000~0FFF		1			4kB CHR bank
  $0000~07FF	2			2kB CHR bank
   $0000~03FF	3			1kB CHR bank
   $0400~07FF	3			1kB CHR bank
  $0800~0FFF	2			2kB CHR bank
   $0800~0BFF	3			1kB CHR bank
   $0C00~0FFF	3			1kB CHR bank
 $1000~1FFF		1			4kB CHR bank
  $1000~17FF	2			2kB CHR bank
   $1000~13FF	3			1kB CHR bank
   $1400~17FF	3			1kB CHR bank
  $1800~1FFF	2			2kB CHR bank
   $1800~1BFF	3			1kB CHR bank
   $1C00~1FFF	3			1kB CHR bank

Sound: $5000-$5015

System state mirroring: $2000, $2001, $2002, $2005, $2006, $4014

PRG mode: $5100[1:0], 3 on reset
CHR mode: $5101[1:0], ? on reset
PRG RAM unlock: $5102[1:0] and $5103[1:0]
Internal RAM ($5C00~5FFF) mode: $5104[1:0]
Nametable mapping: $5105[7:0] 4x 2 bits, 0:CIRAM0, 1:CIRAM1, 2:Internal RAM, 3:Fill mode
$5106[7:0] fill mode tile number
$5107[1:0] fill mode palette attribute

			Mode 0		Mode 1		Mode 2		Mode 3
$6000~7FFF	$5113[3:0]	$5113[3:0]	$5113[3:0]	$5113[3:0]
$8000~9FFF	$5117[6:2]	$5115[6:1]	$5115[6:1]	$5114[6:0]
$A000~BFFF	^			^           ^          	$5115[6:0]
$C000~DFFF  ^           $5117[6:1]	$5116[6:0]  $5116[6:0]
$E000~FFFF  ^           ^          	$5117[6:0]  $5117[6:0]

$5113[3:0] (RAM only) to pins PRG_RAM_A[16:13]
$5114[7]: Select ROM or RAM
$5115[7]: Select ROM or RAM
$5116[7]: Select ROM or RAM
$5117[6:0] (ROM only) to pins PRG_ROM_A[19:13]

$5120~512B: CHR bank (1kB granulaity)
$5130: CHR bank top bits (to reach 1024 banks (10 bits) with 1/2kB granularity)

$5200: Vertical split mode
	[7]: Enable
	[6]: Left/right
	[4:0]: Threshold tile count
$5201[7:0]: Vertical split scroll
$5202[7:0]: 4kB CHR bank select for split region pattern table, nametable comes from internal RAM

$5204[7]: Enable scanline IRQ (write)
$5204[7]: Scanline IRQ pending (read)
$5204[6]: In-frame flag (read)

Multiplier: [$5206, $5205] = $5205 * $5206

$5C00~5FFF: Internal RAM
```

# Architecture

```
PRG_A13_OUT: 2 sources			C7[7]			By[7]
PRG_A14_OUT: 4 sources C6[6]	C7[6]	Bx[1]	By[6]
PRG_A15_OUT: 4 sources C6[5]	C7[5]	Bx[2]	By[5]
PRG_A16_OUT: 4 sources C6[4]	C7[4] 	Bx[3]	By[4]
PRG_A17_OUT: 4 sources C6[3]	C7[3]	Bx[4]	By[3]
PRG_A18_OUT: 4 sources C6[2]	C7[2]	Bx[5]	By[2]
PRG_A19_OUT: 4 sources C6[1]	C7[1]	Bx[6]	By[1]
PRG_RAM_A15_B:4 sourcesC6[0]	C7[0]   Bx[7]   By[0]

PRG_RAM_A13_OUT: 3 sources 		C7[7]			By[7]	Bz[0]
PRG_RAM_A14_OUT: 4 sources 		C7[6]	Bx[1]	By[6]	Bz[1]
PRG_RAM_A15_A:   4 sources 		C7[5]	Bx[2]	By[5]	Bz[2]
PRG_RAM_A16_OUT: 4 sources 		C7[4]			By[4]	Bz[3]

Bz must be $5113[3:0]

Register feeds:
Bz[0] = By[7] = C7[7] = Bx[0] = C6[7]
Bz[1] = By[6] = C7[6] = Bx[1] = C6[6]
Bz[2] = By[5] = C7[5] = Bx[2] = C6[5]
Bz[3] = By[4] = C7[4] = Bx[3] = C6[4]
```
