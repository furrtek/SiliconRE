Konami 054358
Toshiba gate array

Security / DMA chip

Used on: Asterix, Sunset Riders

According to a comment in MAME's source, Asterix' use of the chip is pretty comical.
The mentionned routine is at 7F30 in the EAD set ("asterix").
If d7 is >= $100, a simple d7 word copy is done from (a6) to (a5)
If d7 is < $100, two longword parameters are set up at an arbitrary RAM location:
* $22.b,a6.l (source) to $104258 (RAM)
* d7-1.b,a5.l (dest) to $10425C (RAM)
* Finally $64104258.l ($64.b, RAM location of parameters) to $380800 (dedicated 054358 register)

Sunset Riders is a bit more serious about it.

Latch R: 16-bit latch controlled by R125/T135, fet by DB_IN_LATCH[15:8]
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


There's a 16-bit latch on DBx_IN, controled by DB_IN_LATCH and providing DBx_IN_LATCH.
Possibly the DMA read latch.

DBx_IN_LATCH goes to:
* Another 16-bit latch controller by ?, which outputs are treated as 4 4-bit groups selected by 4-to-1 muxes
  and ANDed together: FEDCBA9876543210
  &{C,8,4,0} or &{D,9,5,1} or &{E,A,6,2} or &{F,B,7,3}
* Another 16-bit latch controlled by V6. The LSB and MSB seem to be used differently in muxes.


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

MUX5 sheet:
V111: W94 ?
V106: P130 and N126 outputs
X140: Outputs of B registers in TRI MUXes
W86:  Outputs of B registers in TRI MUXes
W100: Outputs of B registers in TRI MUXes

Outputs go to TRI MUX A and TRI MUX D

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
