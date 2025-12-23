# Fujitsu AV series gate array cells

Cell names and BC sizes from "CMOS Channeled Gate Arrays 1989 Data Book".

See JPG files for mugshots, and PNG files for RE'd layout and I/O locations.

Thanks to Mathieu Demange for contributions.

## Color code

 * Orange: M1 metal
 * Yellow: M2 metal
 * Blue: Ground rail (M1)
 * Red: Positive rail (M1)
 * Green: Poly (gates)
 * Purple: Active
 * Black: M1 to poly or active via
 * Brown: M2 to M1 via

| Name | BCs | Function 					| In | Out | RE'd |
|-----|---|---------------------------------|----|-----|--------|
| V1N | 1 | Inverter 						| 1 | 1 | Yes |
| V2B | 1 | Power inverter 					| 1 | 1 | Yes |
| N2N | 1 | NAND2 							| 2 | 1 | Yes |
| R2N | 1 | NOR2 							| 2 | 1 | Yes |
| K1B | 2 | Clock buffer 					| 1 | 1 | Yes |
| N2P | 2 | Power AND2 						| 2 | 1 | Yes |
| R2P | 2 | Power OR2 						| 2 | 1 | Yes |
| N3N | 2 | NAND3 							| 3 | 1 | Yes |
| R3N | 2 | NOR3 							| 3 | 1 | Yes |
| D23 | 2 | 2-wide 2AND 3-in AOI 			| 3 | 1 | Yes |
| G23 | 2 | 2-wide 2OR 3-in OAI 			| 3 | 1 | Yes |
| V3A | 2 | 1:2 selector 					| 3 | 2 | No |
| N4N | 2 | NAND4 							| 4 | 1 | Yes |
| R4N | 2 | NOR4 							| 4 | 1 | Yes |
| D14 | 2 | 2-wide 3AND 4-in AOI 			| 4 | 1 | Yes |
| D24 | 2 | 2-wide 2AND 4-in AOI 			| 4 | 1 | Yes |
| D34 | 2 | 3-wide 2AND 4-in AOI 			| 4 | 1 | Yes |
| D44 | 2 | 2-wide 2OR 2AND 4-in AOI 		| 4 | 1 | No |
| G14 | 2 | 2-wide 3OR 4-in OAI 			| 4 | 1 | Yes |
| G24 | 2 | 2-wide 2OR 4-in OAI 			| 4 | 1 | Yes |
| G34 | 2 | 3-wide 2OR 4-in OAI 			| 4 | 1 | Yes |
| G44 | 2 | 2-wide 2AND 2OR 4-in OAI 		| 4 | 1 | Yes |
| T2B | 2 | 2:1 selector 					| 4 | 1 | Yes |
| T2D | 2 | 2:1 selector 					| 4 | 1 | Yes |
| K2B | 3 | Power clock buffer 				| 1 | 1 | Yes |
| K3B | 3 | Gated clock buffer AND 			| 2 | 1 | Yes |
| K4B | 3 | Gated clock buffer OR 			| 2 | 1 | Yes |
| N2B | 3 | Power NAND2 					| 2 | 1 | Yes |
| N3B | 3 | Power NAND3 					| 3 | 1 | Yes |
| N3P | 3 | AND3 							| 3 | 1 | Yes |
| N4P | 3 | AND4 							| 4 | 1 | Yes |
| R2B | 3 | Power NOR2 						| 2 | 1 | Yes |
| R3B | 3 | Power NOR3 						| 3 | 1 | Yes |
| R3P | 3 | OR3 							| 3 | 1 | Yes |
| R4P | 3 | OR4 							| 4 | 1 | Yes |
| D36 | 3 | 3-in AOI 						| 6 | 1 | No |
| V3B | 3 | Dual 1:2 selector 				| 4 | 4 | No |
| N4B | 4 | Power NAND4 					| 4 | 1 | Yes |
| R4B | 4 | Power NOR4 						| 4 | 1 | Yes |
| X1B | 4 | Power XNOR 						| 2 | 1 | Yes |
| X2B | 4 | Power XOR 						| 2 | 1 | Yes |
| T2C | 4 | Dual 2:1 selector 				| 6 | 2 | Yes |
| LT1 | 4 | SR latch with clear				| 3 | 2 | Yes |
| LT2 | 4 | 1-bit data latch 				| 2 | 2 | Yes |
| LTK | 4 | Data latch 						| 2 | 2 | Yes |
| N6B | 5 | Power NAND6 					| 6 | 1 | Yes |
| R6B | 5 | Power NOR6 						| 6 | 1 | Yes |
| T32 | 5 | Power 3AND 2-wide MUX 			| 6 | 1 | Yes |
| U32 | 5 | Power 3OR 2-wide MUX 			| 6 | 1 | Yes |
| T5A | 5 | 4:1 selector 					| 10 | 1 | Yes |
| LTL | 5 | Data latch with clear 			| 3 | 2 | Yes |
| DE2 | 5 | 2:4 decoder 					| 2 | 4 | Yes |
| BD3 | 5 | Delay cell 						| 1 | 1 | Yes |
| N8B | 6 | Power NAND8 					| 8 | 1 | Yes |
| R8B | 6 | Power NOR8 						| 8 | 1 | Yes |
| T24 | 6 | Power 2AND 4-wide MUX 			| 8 | 1 | Yes |
| T42 | 6 | Power 4AND 2-wide MUX 			| 8 | 1 | No |
| U24 | 6 | Power 2OR 4-wide MUX 			| 8 | 1 | Yes |
| U42 | 6 | Power 4OR 2-wide MUX 			| 8 | 1 | No |
| FDM | 6 | DFF 							| 2 | 2 | Yes |
| N9B | 7 | Power NAND9 					| 9 | 1 | Yes |
| R9B | 7 | Power NOR9 						| 9 | 1 | Yes |
| T33 | 7 | Power 3AND 3-wide MUX 			| 9 | 1 | Yes |
| U33 | 7 | Power 3OR 3-wide MUX 			| 9 | 1 | No |
| FD6 | 7 | DFF 							| 2 | 2 | Yes |
| FDN | 7 | DFF with set					| 3 | 2 | Yes |
| FDO | 7 | DFF with reset 					| 3 | 2 | Yes |
| SM2 | 7 | Schmitt trigger input 			| 1 | 2 | No |
| FD2 | 8 | Power DFF 						| 2 | 2 | Yes |
| FD7 | 8 | DFF with clear 					| 3 | 2 | Yes |
| FDP | 8 | DFF with set and reset 			| 4 | 2 | Yes |
| A1N | 8 | 1-bit full adder 				| 3 | 2 | Yes |
| SM1 | 8 | Schmitt trigger input 			| 1 | 2 | Yes |
| NCB | 9 | Power NAND12 					| 12 | 1 | No |
| RCB | 9 | Power NOR12 					| 12 | 1 | No |
| T26 | 9 | Power 2AND 6-wide MUX 			| 12 | 1 | Yes |
| T34 | 9 | Power 3AND 4-wide MUX 	  		| 12 | 1 | Yes |
| T43 | 9 | Power 4AND 3-wide MUX 	  		| 12 | 1 | No |
| U26 | 9 | Power 2OR 6-wide MUX 			| 12 | 1 | No |
| U34 | 9 | Power 3OR 4-wide MUX 			| 12 | 1 | No |
| U43 | 9 | Power 4OR 3-wide MUX 			| 12 | 1 | No |
| FD3 | 9 | Power DFF with preset 	  		| 3 | 2 | No |
| FD5 | 9 | Power DFF with clear 			| 3 | 2 | No |
| FD8 | 9 | DFF and latch 					| 3 | 2 | Yes |
| FDG | 9 | Posedge power DFF 				| 3 | 2 | Yes |
| BD5 | 9 | Delay cell 						| 1 | 1 | Yes |
| FD4 | 10 | Power DFF with clear and preset	| 4 | 2 | No |
| FDE | 10 | Posedge power DFF with clear	| 3 | 2 | Yes |
| KCB | 11 | Block clock buffer 			| 1 | 1 | Yes |
| NGB | 11 | Power NAND16 					| 16 | 1 | No |
| RGB | 11 | Power NOR16 					| 16 | 1 | No |
| T28 | 11 | Power 2AND 8-wide MUX 			| 16 | 1 | No |
| T44 | 11 | Power 4AND 4-wide MUX 			| 16 | 1 | Yes |
| U28 | 11 | Power 2OR 8-wide MUX 			| 16 | 1 | No |
| U44 | 11 | Power 4OR 4-wide MUX 			| 16 | 1 | No |
| FDD | 11 | Posedge power DFF with clear and preset	| 4 | 2 | No |
| FJ4 | 11 | Power JKFF with clear 			| 4 | 2 | No |
| C11 | 11 | FF for counter 				| 5 | 2 | Yes |
| FJ5 | 12 | Power JKFF with clear and preset	| 5 | 2 | No |
| FJD | 12 | Posedge power JKFF with clear	| 4 | 2 | Yes |
| LT4 | 13 | 4-bit data latch 				| x | x | Yes |
| LT3 | 15 | 4-bit data latch 				| 5 | 8 | No |
| LTM | 15 | 4-bit data latch with clear	| 6 | 8 | Yes |
| DE3 | 15 | 3:8 decoder 					| 3 | 8 | Yes |
| A2N | 16 | 2-bit full adder 				| 5 | 3 | Yes |
| BD6 | 17 | Delay cell 					| 1 | 1 | No |
| FS1 | 18 | 4-bit SIPO 					| 2 | 4 | Yes |
| FDS | 20 | 4-bit DFF 						| 5 | 4 | Yes |
| FDQ | 21 | 4-bit DFF 						| 5 | 4 | Yes |
| C41 | 24 | 4-bit binary async counter		| 2 | 4 | Yes |
| FDR | 26 | 4-bit DFF with clear 			| 6 | 4 | Yes |
| FS2 | 30 | 4-bit shift register with sync load	| 7 | 4 | No |
| C42 | 32 | 4-bit binary sync counter		| 2 | 4 | Yes |
| FS3 | 34 | 4-bit shift register with async load	| 7 | 4 | Yes |
| MC4 | 42 | 4-bit magnitude comparator		| 11 | 3 | Yes |
| C43 | 48 | 4-bit binary sync up counter | 9 | 5 | Yes |
| C45 | 48 | 4-bit binary sync up counter | 9 | 5 | Yes |
| A4H | 50 | 4-bit full adder				| 9 | 5 | Yes |
| C47 | 68 | 4-bit binary sync up/down counter	| 8 | 5 | No |
