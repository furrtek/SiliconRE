# Konami 053936

 * Manufacturer: Fujitsu
 * Type: Channelled double column gate array
 * Die markings: 605902
 * Function: "PSAC2" ROZ plane generator
 * Used in: Balzing Tornado, Dragon Ball Z 2, F-1 Grand Prix, Gaiapolis, Golfing Greats, Lethal Crash Race, Monster Maulers, Premier Soccer, Run and Gun, Super Slams

Uses two 24-bit signed accumulators for the pixel lookup positions.

Can auto-load registers 2, 3, 4 and 5 each line from external RAM.

# Registers

* Lower/upper 0: 16-bit X starting value, loaded in Xacc[23:8] by H100A. Lower byte set to 0.
* Lower/upper 1: 16-bit Y starting value, loaded in Yacc[23:8] by H99. Lower byte set to 0.
* Lower/upper 2: value added to X accumulator after each line by H131A:
  * Reg L6 D7 = 0: Xacc += {{8{regU2[7]}}, regU2, regL2}
  * Reg L6 D7 = 1: Xacc += {regU2, regL2, 8'h00}
* Lower/upper 3: value added to Y accumulator after each line by F152:
  * Reg U6 D7 = 0: Yacc += {{8{regU3[7]}}, regU3, regL3}
  * Reg U6 D7 = 1: Yacc += {regU3, regL3, 8'h00}
* Lower/upper 4: value added to X accumulator after each pixel by H104A:
  * Reg L6 D6 = 0: Xacc += {{8{regU4[7]}}, regU4, regL4}
  * Reg L6 D6 = 1: Xacc += {regU4, regL4, 8'h00}
* Lower/upper 5: value added to Y accumulator after each pixel by F140A:
  * Reg U6 D6 = 0: Yacc += {{8{regU5[7]}}, regU5, regL5}
  * Reg U6 D6 = 1: Yacc += {regU5, regL5, 8'h00}
* 6:
  * D[5:0]: Out of bounds mask for XAcc[23:18] (signed, so OOB occurs on both edges), all 1's means no mask
  * D6: Set X pixel update << 8
  * D7: Set X line update << 8
  * D[13:8]: Out of bounds mask for YAcc[23:18] (signed, so OOB occurs on both edges), all 1's means no mask
  * D14: Set Y pixel update << 8
  * D15: Set Y line update << 8
* 7:
  * D[1:0]: Selects pixel delay between M121B and M136 (0 to 3)
  * D2: Start state for window SR registers (how is this useful ?)
  * D3: Invert window
  * D4: Disable window function
  * D5: Enable layer (disabled forces OOB)
  * D6: Enable automatic register update
  * Other bits are unused
* 8: Window min X 10-bit
* 9: Window max X 10-bit
* 10: Window min Y 9-bit
* 11: Window max Y 9-bit
* 12: Start value for pixel counter [9:0], used for window X
* 13: Start value for line counter [8:0], used for window Y
* 14: Start value for external RAM address counter [8:0] loaded on new frame, can wrap
* There's no register 15

Reg 7 D[5:4]:
* 00: Always OOB
* 01: Always OOB
* 10: Window active
* 11: Window inactive

The 14-bit pixel X output {X[12:0], XH} is AccX[23:10], the 14-bit pixel Y output {Y[12:0], YH} is AccY[23:10]
