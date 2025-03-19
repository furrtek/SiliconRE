Texas Instruments TAL004 TTL gate array

CF37201 notes
TI TAL004 TTL array
DIP40
Used in Indoor Soccer
Helps sprite rendering, excuse for a custom chip for protection
Not smart enough to fetch sprite RAM by itself, needs to be configured by 3rd Z80 every new sprite

# Pinout

PIN	NAME	DIR			Notes
1	?		OUTPUT2		Odd/even DRAM address (shared), pixel write position
2	?		OUTPUT2		Odd/even DRAM address (shared), pixel write position
3	?		OUTPUT2		Odd/even DRAM address (shared), pixel write position
4	?		OUTPUT2		Odd/even DRAM address (shared), pixel write position
5	?		OUTPUT 		Used to add +1 to odd/even DRAM address for sprites with an odd X position ?
6	?		OUTPUT2		Odd/even DRAM address (shared), pixel write position
7	?		OUTPUT2		Odd/even DRAM address (shared), pixel write position
8	?		OUTPUT2		Odd/even DRAM address (shared), pixel write position
9	?		OUTPUT2		Odd/even DRAM address (shared), pixel write position
10	VCC		POWER
11	?		OUTPUT2		Odd/even DRAM data (pulled up), sprite palette
12	?		OUTPUT2		Odd/even DRAM data (pulled up), sprite palette
13	?		OUTPUT2		Odd/even DRAM data (pulled up), sprite palette
14	?		OUTPUT2		Odd/even DRAM data (pulled up), sprite palette
15	?		OUTPUT2		Odd/even DRAM data (pulled up), sprite palette
16	BLK		INPUT2      Output of '74 /Q N4
17	H0		INPUT       MCLK / 4 = 9.828MHz / 4 = 2.457MHz
18	*/H0	INPUT2      Inverted H0 (1x P3)
19	?		OUTPUT		Odd/even DRAM data LSB select, H flip ?
20	GND		POWER
21	D0		INPUT		MPB bus (Z80 A1 data)
22	D1		INPUT		MPB bus
23	D2		INPUT		MPB bus
24	D3		INPUT		MPB bus
25	D4		INPUT		MPB bus
26	D5		INPUT		MPB bus
27	D6		INPUT		MPB bus
28	D7		INPUT 		MPB bus
29	A1		INPUT		MPB bus (Z80 A1 address)
30	A0		INPUT		MPB bus (Z80 A1 address)
31	VCC		POWER
32	B1		INPUT		MPB bus (Z80 A1 /MR19 & address[15:14] == 1)
33	?		INPUT		FIELD / 2 (Frame odd/even ?)
34	?		OUTPUT		Common to XORs, H flip
35	?		OUTPUT		Common to XORs, V flip
36	//H0	INPUT       Delayed H0 (1x P3, 1x M2, 2x D3)
37	/PL		INPUT2		counter [7] == 1, 0 resets counter to 0b10000001 (counts 126 ?), sprite blitting done
38	?		INPUT2		High when counter [2:0] == 0, when one sprite line has been blitted (8 bytes = 16 pixels)
39	*PACC	INPUT       Z80 A1 pin 20 /IORQ
40	*PINT	OUTPUT      Z80 A1 pin 16 /INT, ANDed with R3 (/MAB[12:11] == 3 & /B4 = /MAB[15:13] == 4: 9800~9FFF)

Sprite graphics format: 16x16 pixels, 4 bits per pixel, with 1 bit for opacity and 3 for indexed color ?
Frame buffers: odd/even fields, 8 bits, 3 color + 5 palette
Pair of groups of 8 TMS4164 (2x 64kBytes)
Address: a  b  c  d  e  f  g  h
		 H1 H2 H3 H4 H5 H6 H7 V0
		 V1 V2 V3 V4 V5 V6 V7 F

Where does the OAB signal come from ?

Pin 36 controls an octal 2-to-1 mux for pins 1, 2, 3, 4, 6, 7, 8, 9

Inc X when rising edge /nH0 NAND BLK
Inc Y when rising edge (/nH0 NAND BLK) AND PIN_38

MCLK	_'_'_'_'_'_'_'_'_'_'_'_'_'_'_'_'_'_	9.828MHz
Q0      _''__''__''__''__''__''__''__''__'' 4.914MHz (pixel clock inverted)
Q1=H0   ___''''____''''____''''____''''____ 2.457MHz (pixel X0)
Q2      _______''''''''________''''''''____ 1.2285MHz (pixel X1)
Q3      _______________''''''''''''''''____ 0.61425MHz (CRTC clock)

RAS		_''______''______''______''______''
CAS		___''______''______''______''______

Sprite X: 0
	Write pixel 0 to even 0
	Write pixel 1 to odd 0
	Write pixel 2 to even 1
	Write pixel 3 to odd 1...
Sprite X: 1
	Write pixel 0 to odd 0
	Write pixel 1 to even 1
	Write pixel 2 to odd 1
	Write pixel 3 to even 2...
