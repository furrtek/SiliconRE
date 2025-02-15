# Konami 054358

 * Manufacturer: Toshiba
 * Type: Gate array
 * Die markings: CD05 0009
 * Die picture: https://siliconpr0n.org/map/konami/054358/furrtek_mz/
 * Function: DMA/Security
 * Used in: Asterix, Sunset Riders
 * Chip donator: @Ace646546

According to a comment in MAME's source, Asterix' use of the chip is pretty comical.
The mentionned routine is at 7F30 in the EAD set ("asterix").
If d7 is >= $100, a simple d7 word copy is done from (a6) to (a5)
If d7 is < $100, two longword parameters are set up at arbitrary RAM locations:
 * {$22[7:0], a6[23:0]} (source) to $104258 (RAM)
 * {d7-1[7:0], a5[23:0]} (dest) to $10425C (RAM)
 * Finally $64104258.l ({$64[7:0], RAM location of parameters}) to $380800 (dedicated 054358 register)

So the chip seems to work on 8-bit commands and 24-bit addresses. Do they have the same format when written directly to $380800 and when automatically read ?
 * $64 would mean "Run indirect", ie. read commands from provided address
 * $22 would mean "DMA block copy words", source, size, destination

Sunset Riders is a bit more serious about it.

# How it werks

Full 68k address and data lines, everything needed to do DMA, IRQ output, MLWR input used to access DMA registers
Can't read UDS nor LDS, so all writes to the chip are considered to be 16-bit.

## RAM access interception

Hardwired address triggers are used to intercept writes (and reads ?) to:

* 0x105CB0: DB_IN_LAT -> 16-bit REGE
* 0x105A0A: Sets LATCHX and/or LATCHZ under some conditions ?
* 0x105818: Sets B latches in TRIMUXA
* 0x105C86: DB_IN_LAT -> 16-bit REGF, and triggers something
* 0x1058FC: DB_IN_LAT -> NIB latches

These random and innocent looking addresses are in the work RAM area of both Asterix and Sunset Riders.
Interception isn't active when the chip is busy.

## Other

ssriders_protection_r: 0x1C0800~1
ssriders_protection_w: 0x1C0800~3

The write to 0x1C0802 triggers:
* var = 1
* ...

Active high selects, mutually exclusive:
J148
J88
COM3
D152

1058FCWR sets a 16-bit latch, and a 4-bit one with DB[15:12]_IN_LAT only
Doesn't look like a tracing mistake, so there might be multiple modes/functions
in the same chip.


Latch R: 16-bit latch controlled by R125/T135, fed by DB_IN_LATCH[15:8]
N126, P130, V131, Y125

Latch V: 16-bit latch controlled by G118
E77 E83 C71 A93, A50 B50 B38 E30, G147? K144 E163? E156, L24 L12 M16 L20

Latch W: 8-bit latch controlled by N94
DUAL MUXES C, DUAL MUXES D

Latch X: 8-bit latch controlled by K99
DUAL MUXES C, DUAL MUXES D

Latch Y: 8-bit latch controlled by K108
DUAL MUXES A, DUAL MUXES B

Latch Z: 8-bit latch controlled by J112
DUAL MUXES A, DUAL MUXES B

DB_OUT[7:0] comes from 4 possible sources:
* COM3/J88/C166/D158: Latch V
* COM3/J88/C166/D158: Latch V inverted
* J148: R66 R72 T70 S60, R24 T38 R31 N58 (Latch W)
* D152: L61 M68 N74 R54, P34 R36 P39 N48 (Latch X)

DB_OUT[15:8] comes from 5 possible sources. The additionnal one is DB_OUT[7:0] which means that
there's a write mode where the MSB replicates the LSB.
* C166/D158: Latch V
* C166/D158: Latch V inverted
* C157?: D113 C127 E94 D127, A103 E105 J105 D100 (Latch Y)
* D154: F114 B127 E100 D137, A126 D105 G110 C100 (Latch Z)
* C164: DB_OUT[7:0]

Are latches W and Y paired ?
Are latches X and Z paired ?


There's a 16-bit latch on DBx_IN, controled by DB_IN_LATCH and providing DBx_IN_LATCH.
Possibly the DMA data read latch.

DBx_IN_LATCH goes to:
* Another 16-bit latch controller by ?, which outputs are treated as 4 4-bit groups selected by 4-to-1 muxes
  and ANDed together: FEDCBA9876543210
  &{C,8,4,0} or &{D,9,5,1} or &{E,A,6,2} or &{F,B,7,3}
* Another 16-bit latch controlled by V6. The LSB and MSB seem to be used differently in muxes.
* DB[15:8]_IN_LATCH to another latch, then a XOR comparator with P130/N126
* DB[15:8]_IN_LATCH to another latch P130/N126 "LATB"


DBx_IN_LATCH[15:12] to mux3
DBx_IN_LATCH[15:12] to mux3

DBx_IN_LATCH[11:8] to mux3
DBx_IN_LATCH[7:4] to mux3
DBx_IN_LATCH[7:4] to mux3
DBx_IN_LATCH[3:0] to mux3
DBx_IN_LATCH[3:0] to mux3

DUAL MUXES sheets:
Sixteen 4- or 5- to 1 muxes that each feed two groups of sixteen registers.
D: 5-to-1's
	M106/G116 selects DB DBx_IN_LATCH[3:0]
	K126/P84 selects DB DBx_IN_LATCH[8:11]
	M102/G122 selects XORs on MUXES page
	E128/K124 selects XORs on MUXES page
	COM11 selects ?
C: 5-to-1's
	M106/G116 selects DB DBx_IN_LATCH[4:7]
	K126/P84 selects DB DBx_IN_LATCH[12:15]
	M102/G122 selects ?
	E128/K124 selects XORs on MUXES page
	COM11 selects ?
B: 4-to-1's
	M106/G116 selects DB DBx_IN_LATCH[12:15]
	K126/P84 selects DB DBx_IN_LATCH[4:7]
	M102/G122 selects XORs on MUXES page
	G120 selects ?
A: 4-to-1's
	M106/G116 selects DB DBx_IN_LATCH[8:11]
	K126/P84 selects DB DBx_IN_LATCH[0:3]
	M102/G122 selects XORs on MUXES page
	G120 selects ?

# MUX5

The output of MUX5 (8-bit) gets added to or subtracted from the base address for final address output.

W94:  {{6{V111}}, R130, V121}
V106: LATB
X140: Outputs of B registers in TRIMUX B
W86:  Outputs of B registers in TRIMUX B
W100: Outputs of B registers in TRIMUX B

Outputs go to TRI MUX A and TRI MUX D

AB[23:1] pins are all BIDIR.

Replicated logic drivers:
T135 = R125
V78 = Y103 = Y70
Y116 = Y83 = Y124
AB80 = AB82
N110 = G120
E128 = K124
P84 = K126
G116 = M106
G122 = M102
Z96 = AA91 = AB134
AA140 = AA89
G54 = S54
S58 = J66
