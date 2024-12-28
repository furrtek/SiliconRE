# Oki MSM70000 series gate array cells

Cell names and BC sizes from the MSM70V000 series datasheet.

See PNG files for mugshots and RE'd layout with I/O locations.

| Name | BCs | Function 			        	| In | Out | Listed |
|------|----|-----------------------------------|----|-----|--------|
| 2ND  | 1  | 	2-input NAND					| 1	 | 2   | OK
| 2NR  | 1  | 	2-input NOR				    	| 1	 | 2   | OK
| G301 | 1  | 	Driver				    	    | 1	 | 1   |
| G402 | 1  | 	Inverter driver		    	    | 1	 | 1   |
| G901 | 1  | 	Fixed high and low	    	    | 0	 | 2   |
| HFX  | 1  |	Fixed high	    	            | 0	 | 1   |
| INV  | 1  |	Inverter			    	    | 1	 | 1   | OK
| INV2 | 1  | 	Dual inverter			    	| 2	 | 2   | OK
| LFX  | 1  |	Fixed low			    	    | 0	 | 1   | OK
| 22AR | 2  | 	2-input 2-wide AND-NOR			| 4	 | 1   |
| 2AD  | 2  |	2-input AND	2	2	1	OK
| 2ND2 | 2  | 	Dual 2-input NAND	2	4	2
| 2NR2 | 2  | 	Dual 2-input NOR	2	4	2
| 2OR  | 2  |	2-input OR	2	2	1	OK
| 3AD  | 2  |	3-input AND	2	3	1	OK
| 3ND  | 2  |	3-input NAND	2	3	1	OK
| 3NR  | 2  |	3-input NOR	2	3	1	OK
| 3OR  | 2  |	3-input OR	2	3	1
| 4ND  | 2  |	4-input NAND	2	4	1	OK
| 4NR  | 2  |	4-input NOR	2	4	1	OK
| D1A  | 2  |	Driver	2	1	1	OK
| G101 | 2  | 	2-1 input 2-wide AND-NOR	2
| G102 | 2  | 	2-1-1 input 3-wide AND-NOR	2
| G103 | 2  | 	3-1 input 2-wide AND-NOR	2
| G104 | 2  | 	2-input OR into 2-1 input 2-wide AND-NOR	2
| G201 | 2  | 	2-1 input 2-wide OR-NAND	2
| G202 | 2  | 	2-1-1 input 3-wide OR-NAND	2
| G203 | 2  | 	3-1 input 2-wide OR-NAND	2
| G204 | 2  | 	2-input AND into 2-1 input 2-wide OR-NAND	2
| G205 | 2  | 	2-input 2-wide OR-NAND	2	4	1
| G302 | 2  | 	Driver	2	1	1
| G403 | 2  | 	Inverter driver	2	1	1
| G404 | 2  | 	Inverter driver	2	1	1
| 220  | 3  |	2-input 2-wide AND-OR	3	4	1	OK
| 2AD2 | 3  | 	Dual 2-input AND	3	4	2	OK
| 2OR2 | 3  | 	Dual 2-input OR	3	4	2	OK
| 4AD  | 3  |	4-input AND	3	4	1	OK
| 4OR  | 3  |	4-input OR	3	4	1	OK
| BHD1 | 3  | 	Bus hold	3
| D1N  | 3  |	Inverter driver	3	1	1	OK
| D2A  | 3  |	Driver	3	1	1	OK
| D2AD | 3  | 	2-input AND driver	3	2	1
| D2ND | 3  | 	2-input NAND driver	3	2	1
| DLT1 | 3  | 	D-latch	3	2	2?	Negedge
| EXR  | 3  |	XOR	3	2	1	OK
| ENR  | 3  |	XNOR	3	2	1	OK
| G107 | 3  | 	2-input 3-wide AND-NOR	3	6	1
| G111 | 3  | 	3-input 2-wide AND-NOR	3	6	1
| G117 | 3  | 	2-input AND and 2-input NOR into 2-input NOR	3	4	1
| G207 | 3  | 	2-input 3-wide OR-NAND	3	6	1
| G211 | 3  | 	3-input 2-wide OR-NAND	3	6	1
| G217 | 3  | 	2-input OR and 2-input NAND into 2-input NAND	3	4	1
| G304 | 3  | 	Driver	3	1	1
| L204 | 3  | 	D-latch	3	2	2?	Posedge
| LTND | 3  |	S-R NAND latch	3
| LTNR | 3  | 	S-R NOR latch	3
| 2SE  | 4  |	2-to-1 selector	4	3	1	74157
| 5AD  | 4  |	5-input AND	4	5	1	OK
| 5ND  | 4  |	5-input NAND	4	5	1	OK
| 5NR  | 4  |	5-input NOR	4	5	1
| 5OR  | 4  |	5-input OR	4	5	1
| 6AD  | 4  |	6-input AND	4	6	1
| 6OR  | 4  |	6-input OR	4	6	1
| D2N  | 4  |	Inverter driver	4	1	1
| DLT  | 4  |	D-latch with reset	4	3	1	/LE
| G108 | 4  | 	2-input 4-wide AND-NOR	4	8	1
| G114 | 4  | 	4-input 2-wide AND-NOR	4	8	1
| G208 | 4  | 	2-input 4-wide OR-NAND	4	8	1
| G214 | 4  | 	4-input 2-wide OR-NAND	4	8	1
| L101 | 4  | 	S-R latch with enable	4
| L102 | 4  | 	S-R latch with clear	4
| L203 | 4  | 	D-latch with /reset	4	3	2?	Negedge
| L205 | 4  | 	D-latch with /reset	4	3	2?	Posedge
| TB01 | 4  | 	Tristate driver	4	2?	1
| TB11 | 4  | 	Tristate inverter driver	4	2?	1
| TBD1 | 4  | 	Tristate driver	4	2?	1
| 6ND  | 5  |	6-input NAND	5	6	1	OK
| 6NR  | 5  |	6-input NOR	5	6	1
| 7AD  | 5  |	7-input AND	5	7	1
| 7ND  | 5  |	7-input NAND	5	7	1
| 7NR  | 5  |	7-input NOR	5	7	1
| 7OR  | 5  |	7-input OR	5	7	1
| 8AD  | 5  |	8-input AND	5	8	1
| 8OR  | 5  |	8-input OR	5	8	1
| G703 | 5  | 	Delay 30ns	5	1	1
| TBD2 | 5  | 	Tristate driver	5	2?	1
| 330  | 6  |	3-input 3-wide AND-OR	6	9	1	OK
| 4DE1 | 6  | 	2-to-4 decoder	6	2	4
| 8ND  | 6  |	8-input NAND	6	8	1	OK
| 8NR  | 6  |	8-input NOR	6	8	1	OK
| CB4  | 6  |	Driver and inverter driver	6	1	2?
| DFF  | 6  |	DFF	6	2?	2?	Posedge
| F121 | 6  | 	DFF	6	2?	2?	Negedge
| G701 | 6  | 	Delay 10ns	6	1	1
| 1FA  | 7  |	1-bit full adder	7
| D3N  | 7  |	Inverter driver	7	1	1	OK
| F112 | 7  | 	DFF with reset	7	3	2?	Posedge
| F113 | 7  | 	DFF with set	7	3	2?	Posedge
| F115 | 7  | 	DFF with /reset	7	3	2?	Posedge
| F116 | 7  | 	DFF with /set	7	3	2?	Posedge
| F125 | 7  | 	DFF with /reset	7	3	2?	Negedge
| F126 | 7  | 	DFF with /set	7	3	2?	Negedge
| F312 | 7  | 	Toggle FF with reset	7			Posedge
| F313 | 7  | 	Toggle FF with set	7			Posedge
| F316 | 7  | 	Toggle FF with /set	7			Posedge
| F325 | 7  | 	Toggle FF with reset	7			Negedge
| F326 | 7  | 	Toggle FF with /set	7			Negedge
| TBD3 | 7  | 	Tristate driver	7	2?	1
| TFR1 | 7  | 	Toggle FF with /reset	7			Posedge
| 4SE  | 8  |	4-to-1 selector	8	6	1	74153
| DF1  | 8  |	DFF with /set and /reset	8	4	2?	Posedge
| DFR  | 8  |	DFF with reset	8	3	2	Posedge
| F114 | 8  | 	DFF with set and reset	8	4	2?	Posedge
| F127 | 8  | 	DFF with /set and /reset	8	4	2?	Negedge
| F314 | 8  | 	Toggle FF with set and reset	8			Posedge
| F317 | 8  | 	Toggle FF with /set and /reset	8			Posedge
| F327 | 8  | 	Toggle FF with /set and /reset	8			Negedge
| G109 | 8  | 	2-input 6-wide AND-NOR	8	12	1
| G209 | 8  | 	2-input 6-wide OR-NAND	8	12	1
| TFR  | 8  |	Toggle FF with reset	8			Posedge
| 4DE  | 9  |	2-to-4 decoder with enable	9	3	4	74139
| D3A  | 9  |	Driver	9	1	1	OK
| DF   | 9  |	DFF with set and reset	9	4	2?	OK	Posedge
| F211 | 9  | 	J-K FF	9			Posedge
| F221 | 9  | 	J-K FF	9			Negedge
| 440  | 10 | 	4-input 4-wide AND-OR	10	16	1	OK
| F212 | 10 | 	J-K FF with reset	10			Posedge
| F213 | 10 | 	J-K FF with set	10			Posedge
| F215 | 10 | 	J-K FF with /reset	10			Posedge
| F216 | 10 | 	J-K FF with /set	10			Posedge
| F225 | 10 | 	J-K FF with /reset	10			Negedge
| F226 | 10 | 	J-K FF with /set	10			Negedge
| F401 | 10 | 	Toggle FF with enable, set and reset	10			Posedge
| F402 | 10 | 	Toggle FF with /enable, /set and /reset	10			Negedge
| JKFF | 10 | 	J-K FF	10			Posedge
| LDFR | 10 | 	DFF with reset and LSSD	10			Posedge
| TFRE | 10 | 	Toggle FF with /enable and reset	10			Posedge
| 2SE4 | 11 | 	Quad 2-to-1 selector	11			74158
| 4LT  | 11 |	4-bit latch	11	5	4
| F214 | 11 | 	J-K FF with set and reset	11			Posedge
| F227 | 11 | 	J-K FF with /set and /reset	11			Negedge
| G110 | 11 | 	2-input 8-wide AND-NOR	11	16	1
| G210 | 11 | 	2-input 8-wide OR-NAND	11	16	1
| G702 | 11 | 	Delay 20ns	11	1	1
| JKF1 | 11 | 	J-K FF with /set and /reset	11			Posedge
| JKFR | 11 | 	J-K FF with reset	11			OK	Posedge
| LDF  | 11 |	DFF with set, reset and LSSD	11			Posedge
| TFE  | 12 |	Toggle FF with /enable, set and reset	12			Posedge
| 4LT1 | 13 | 	4-bit latch with reset	13	6	4
| JKF  | 13 | 	J-K FF with set and reset	13			Posedge
| LJKR | 13 |  	J-K FF with reset and LSSD	13			Posedge
| 4CM1 | 14 |  	4-bit equal-to comparator	14	8	1
| R41  | 14 | 	4-bit RAM cell	14
| 2FA  | 15 | 	2-bit full adder	15			7482
| 8DE1 | 15 |  	3-to-8 decoder	15	3	8
| LJKF | 15 |  	J-K FF with set, reset and LSSD	15			Posedge
| 8PG  | 18 | 	8-bit parity generator	18
| 8SE  | 18 | 	8-to-1 selector	18	11	1	74151
| 4CM2 | 22 |  	4-bit magnitude comparator	22	8?
| 4DF  | 19 | 	Quad DFF	19	5?
| 8DE  | 20 | 	3-to-8 decoder with enable	20	4	8	74138
| 8LT  | 21 | 	8-bit latch	21	9?	8
| 4DF1 | 23 |  	Quad DFF with reset	23
| 4RD  | 23 |	4-bit down counter with set	23
| 4RU  | 23 |	4-bit up counter with reset	23			74393
| 4SR  | 23 |	4-bit SR with reset	23
| 8LT1 | 25 | 	8-bit latch with reset	25
| 4CD  | 66 |	Sync 4-bit up/down counter with load	66			74191
| 4CD1 | 56 | 	Sync 4-bit up/down counter with set and reset	56
| 4CU  | 45 |	Sync 4-bit counter with sync reset and load	45			74163
| 4CU1 | 38 | 	Sync 4-bit counter with sync reset	38
| 4FA1 | 38 | 	4-bit full adder with fast carry	38			74283
| 4SR1 | 32 | 	4-bit SR with reset and load	32			74395
| 8SR  | 45 | 	8-bit SR with reset	45			74164
| 8SR1 | 62 | 	8-bit SR with reset and load	62
