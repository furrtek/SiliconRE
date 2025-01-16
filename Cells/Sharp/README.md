# Sharp gate array cells

Original cell names unknown. Mugshots taken from die pictures from John McMaster.

See JPG files for mugshots, and PNG files for RE'd layout and I/O locations.

## Color code

 * Orange: M1 metal
 * Yellow: M2 metal
 * Blue: Ground rail (M1)
 * Red: Positive rail (M1)
 * Green: Poly (gates)
 * Purple: Active
 * Black: M1 to poly or active via
 * Brown: M2 to M1 via

| Name | BCs | Function 			        	| In | Out |
|-----|---|-----------------------------|----|-----|
| BUF | 1 | Buffer 			   | 1 | 1 |
| INV | 1 | Inverter 					     | 1 | 1 |
| NAND2 | 1 | 2-input NAND 		  | 2 | 1 |
| NOR2 | 1 | 2-input NOR 		  | 2 | 1 |
| AND2P | 2 | 2-input power AND 						    | 2 | 1 |
| NAND4 | 2 | 4-input NAND 				   | 4 | 1 |
| NOR3 | 2 | 3-input NOR 		  | 3 | 1 |
| AND4P | 3 | 4-input power AND 						       | 4 | 1 |
| AO22 | 3 | 2-input AND-OR 				   | 4 | 1 |
| MUX2 | 3 | 2:1 mux 						       | 3 | 1 |
| NAND2P | 3 | 2-input power NAND 		  | 2 | 1 |
| XOR | 3 | Exclusive OR 		  | 2 | 1 |
| LAT | 4 | Latch 						     | 2 | 2 |
| NAND5 | 4 | 5-input NAND 						     | 5 | 1 |
| NOR5 | 4 | 5-input NOR 	| 5 | 1 |
| NAND6 | 5 | 6-input NAND 						       | 6 | 1 |
| DFF | 6 | DFF 					   | 2 | 2 |
| NAND7 | 6 | 7-input NAND 		  | 7 | 1 |
| DFFR | 8 | DFF with /reset 					   | 3 | 2 |