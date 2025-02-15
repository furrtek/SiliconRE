# Konami 054000

 * Manufacturer: NEC
 * Type: CMOS-5 gate array, 6-transistor BCs
 * Die markings: 65025-060
 * Die picture: https://siliconpr0n.org/map/konami/054000/furrtek_mz/
 * Function: Collision detection / Security
 * Used in: Thunder Cross 2, Bells & Whistles, Gaiapolis, Bucky O'Hare, Lethal Enforcers, Vendetta
 * Chip donator: @CaiusArcade

Gets loaded with 18 bytes, replies with a single bit. Unused registers are unmapped. No reset signal so initial state may be random.

Both X and Y parts use exactly the same logic, the result of both are ORed together.

Cell_3d is the top two BCs of a 8-bit latch, some traces are wrong ! For illustration only. See pictures of paper notes.

# Pinout
   ______
 1|NC VDD|28
 2|NC   P|27
 3|NC   P|26
 4|NC  NC|25
 5|NC  NC|24
 6|A5  NC|23
 7|A4   P|22
 8|A3  NC|21
 9|A2   P|20
10|A1  D7|19
11|D0  D6|18
12|D1  D5|17
13|D2  D4|16
14|GND_D3|15

* Only D[0] is bidir, D[7:6] are always hi-z.
* P20: High: Use CS + /WR, low: Use R/W
* P22: R/W
* P26: CS
* P27: /WR

# Use

According to MAME the following games use this chip:
* Thunder Cross 2 (@ 0x500000, passes POST without patch, not used in game)
* Bells & Whistles (@ 0x500000)
* Gaiapolis (@ 0x660000, not POSTed but used in game, returning 0 causes player to hit everything on screen)
* Bucky O'Hare (@ 0x0d2000, POST returns "P7 device error" if check fails, used in game, returning 0 causes player to always be hit)
* Lethal Enforcers (@ 0x4880 with CBNK=0, never used ?)
* Vendetta (@ 0x5f80, not POSTed but used in game, returning 0 causes all hit checks to pass)

# Notes

Thunder Cross 2 POST:
Table of test commands starts at 0x14d4, entries are 2 bytes.
First byte is the reg address *2+1 (< 0x30 means write, 0x31 means read), second byte is value.

Value	Regs written to						Expected
00	3,5,7,9,D,F,13,15,17,19,1D,1F,23,25,27,2B,2D,2F		0

FF	3	1
FF	2B	0
FF	5	1
FF	2D	0
FF	7	1
FF	2F	0

FF	13	1
FF	23	0
FF	15	1
FF	25	0
FF	17	1
FF	27	0

FF	9	1
FF	D	0
FF	19	1
FF	F	0

0	D	1
FF	1D	0
0	F	1
FF	1F	0
