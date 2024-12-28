# Fujitsu AV series gate array cells

Cell names and BC sizes from "CMOS Channeled Gate Arrays 1989 Data Book".

See PNG files for mugshots and RE'd layout with I/O locations.

| Name | BCs | Function 			        	| In | Out | Listed |
|-----|---|-----------------------------|----|-----|--------|
| V1N | 1 | Inverter 					      1 | 1 |??
| V2B | 1 | Power inverter 			    1 | 1 |
| N2N | 1 | NAND2 						      2 | 1 | 
| R2N | 1 | NOR2 						        2 | 1 | | 
| K1B | 2 | Clock buffer 				    1 | 1 | | 
| N2P | 2 | Power AND2 					    2 | 1 | | 
| R2P | 2 | Power OR2 					    2 | 1 | | 
| N3N | 2 | NAND3 						      3 | 1 | | 
| R3N | 2 | NOR3 						        3 | 1 | | 
| D23 | 2 | 2-wide 2AND 3-in AOI 		   3 | 1 | | 
| G23 | 2 | 2-wide 2OR 3-in OAI 		   3 | 1 | | 
| V3A | 2 | 1:2 selector 				    3 | 2 |
| N4N | 2 | NAND4 						      4 | 1 | | 
| R4N | 2 | NOR4 						        4 | 1 | | 
| D14 | 2 | 2-wide 3AND 4-in AOI 		   4 | 1 | | 
| D24 | 2 | 2-wide 2AND 4-in AOI 		   4 | 1 | | 
| D34 | 2 | 3-wide 2AND 4-in AOI 		   4 | 1 | | 
| D44 | 2 | 2-wide 2OR 2AND 4-in AOI 	 4 | 1 |
| G14 | 2 | 2-wide 3OR 4-in OAI 		   4 | 1 | | 
| G24 | 2 | 2-wide 2OR 4-in OAI 		   4 | 1 | | 
| G34 | 2 | 3-wide 2OR 4-in OAI 		   4 | 1 | | 
| G44 | 2 | 2-wide 2AND 2OR 4-in OAI 	 4 | 1 | | 
| T2B | 2 | 2:1 selector 				    4 | 1 | | 
| T2D | 2 | 2:1 selector 				    4 | 1 | | 
| K2B | 3 | Power clock buffer 			   1 | 1 | | 
| K3B | 3 | Gated clock buffer AND 		 2 | 1 | | 
| K4B | 3 | Gated clock buffer OR 		 2 | 1 | | 
| N2B | 3 | Power NAND2 				    2 | 1 | | 
| N3B | 3 | Power NAND3 				    3 | 1 | | 
| N3P | 3 | AND3 						        3 | 1 | | 
| N4P | 3 | AND4 						        4 | 1 | | 
| R2B | 3 | Power NOR2 					    2 | 1 | | 
| R3B | 3 | Power NOR3 					    3 | 1 | | 
| R3P | 3 | OR3 						        3 | 1 | | 
| R4P | 3 | OR4 						        4 | 1 | | 
| D36 | 3 | 3-in AOI 					      6 | 1 |
| V3B | 3 | Dual 1:2 selector 	    4 | 4 |
| N4B | 4 | Power NAND4 				    4 | 1 | | 
| R4B | 4 | Power NOR4 					    4 | 1 | | 
| X1B | 4 | Power XNOR 					    2 | 1 | | 
| X2B | 4 | Power XOR 					    2 | 1 | | 
| T2C | 4 | Dual 2:1 selector 	    6 | 2 | | 
| LT1 | 4 | SR latch with clear     3 | 2 | | 
| LT2 | 4 | 1-bit data latch 		    2 | 2 |
| LTK | 4 | Data latch 					    2 | 2 | | 
| N6B | 5 | Power NAND6 				    6 | 1 | | 
| R6B | 5 | Power NOR6 					    6 | 1 | | 
| T32 | 5 | Power 3AND 2-wide MUX 		 6 | 1 | | 
| U32 | 5 | Power 3OR 2-wide MUX 		   6 | 1 | | 
| T5A | 5 | 4:1 selector 				    10 | 1 | | 
| LTL | 5 | Data latch with clear 		 3 | 2 | | 
| DE2 | 5 | 2:4 decoder 				    2 | 4 | | 
| BD3 | 5 | Delay cell 					    1 | 1 | | 
| N8B | 6 | Power NAND8 				    8 | 1 | | 
| R8B | 6 | Power NOR8 					    8 | 1 | | 
| T24 | 6 | Power 2AND 4-wide MUX 		 8 | 1 | | 
| T42 | 6 | Power 4AND 2-wide MUX 		 8 | 1 |
| U24 | 6 | Power 2OR 4-wide MUX 		   8 | 1 | | 
| U42 | 6 | Power 4OR 2-wide MUX 		   8 | 1 |
| FDM | 6 | DFF 						        2 | 2 | | 
| N9B | 7 | Power NAND9 				    9 | 1 | | 
| R9B | 7 | Power NOR9 					    9 | 1 | | 
| T33 | 7 | Power 3AND 3-wide MUX 		 9 | 1 | | 
| U33 | 7 | Power 3OR 3-wide MUX 		   9 | 1 |
| FD6 | 7 | DFF 						        2 | 2 | FDN ! | RDD673106U |
| FDN | 7 | DFF with set				    3 | 2 | | 
| FDO | 7 | DFF with reset 			    3 | 2 | | 
| SM2 | 7 | Schmitt trigger input 		 1 | 2 |
| FD2 | 8 | Power DFF 					    2 | 2 | | 
| FD7 | 8 | DFF with clear 			    3 | 2 | | 
| FDP | 8 | DFF with set and reset 		 4 | 2 | | 
| A1N | 8 | 1-bit full adder 		    3 | 2 | | 
| SM1 | 8 | Schmitt trigger input 		 1 | 2 | 315-5216 |
| NCB | 9 | Power NAND12 				    12 | 1 |
| RCB | 9 | Power NOR12 				    12 | 1 |
| T26 | 9 | Power 2AND 6-wide MUX 		 12 | 1 | | 
| T34 | 9 | Power 3AND 4-wide MUX 	  	| 12 | 1 | | 
| T43 | 9 | Power 4AND 3-wide MUX 	  	| 12 | 1 |
| U26 | 9 | Power 2OR 6-wide MUX 	    	| 12 | 1 |
| U34 | 9 | Power 3OR 4-wide MUX 	    	| 12 | 1 |
| U43 | 9 | Power 4OR 3-wide MUX 	    	| 12 | 1 |
| FD3 | 9 | Power DFF with preset 	  	| 3 | 2 |
| FD5 | 9 | Power DFF with clear 		   3 | 2 |
| FD8 | 9 | DFF and latch 			    3 | 2 | | 
| FDG | 9 | Posedge power DFF 	    3 | 2 | | 
| BD5 | 9 | Delay cell 					    1 | 1 | | 
| FD4 | 10 | Power DFF with clear and preset | 4 | 2 |
| FDE | 10 | Posedge power DFF with clear | 3 | 2 | | 
| KCB | 11 | Block clock buffer 		   1 | 1 | | 
| NGB | 11 | Power NAND16 			    16 | 1 |
| RGB | 11 | Power NOR16 				    16 | 1 |
| T28 | 11 | Power 2AND 8-wide MUX 		 16 | 1 |
| T44 | 11 | Power 4AND 4-wide MUX 		 16 | 1 | | 
| U28 | 11 | Power 2OR 8-wide MUX 		 16 | 1 |
| U44 | 11 | Power 4OR 4-wide MUX 		 16 | 1 |
| FDD | 11 | Posedge power DFF with clear and preset | 4 | 2 |
| FJ4 | 11 | Power JKFF with clear 		 4 | 2 |
| C11 | 11 | FF for counter 		      	| 5 | 2 | | 
| FJ5 | 12 | Power JKFF with clear and preset | 5 | 2 |
| FJD | 12 | Posedge power JKFF with clear | 4 | 2 | | 
| LT4 | 13 | 4-bit data latch 			   | 
| LT3 | 15 | 4-bit data latch 	    5 | 8 |
| LTM | 15 | 4-bit data latch with clear 6 | 8 | | 
| DE3 | 15 | 3:8 decoder 				    3 | 8 | | 
| A2N | 16 | 2-bit full adder 			   | 
| BD6 | 17 | Delay cell 				   
| FS1 | 18 | 4-bit SIPO 				   
| FDS | 20 | 4-bit DFF 					    5 | 4 | | 
| FDQ | 21 | 4-bit DFF 					    5 | 4 | | 
| C41 | 24 | 4-bit binary async counter | 2 | 4 | | 
| FDR | 26 | 4-bit DFF with clear 		 | 
| FS2 | 30 | 4-bit shift register with sync load |
| C42 | 32 | 4-bit binary sync counter 	| | 
| FS3 | 34 | 4-bit shift register with async load | | 
| MC4 | 42 | 4-bit magnitude comparator |
| C43 | 48 | 4-bit binary sync up counter | YES ? | YES ? | | 
| C45 | 48 | 4-bit binary sync up counter | YES ? | YES ? | RDD673106U |
| A4H | 50 | 4-bit full adder
| C47 | 68 | 4-bit binary sync up/down counter |
