Inputs for 5 layers:
CI0, CI1, CI2: 5+4 bits
CI3, CI4: 4+4 bits

Output: 11-bit palette index
B: Base, P: Palette #, C: Color
         A9876543210
For CI0: BBPPPPPCCCC    BB: Reg9[1:0]
For CI1: BBPPPPPCCCC    BB: Reg9[3:2]
For CI2: BBPPPPPCCCC    BB: Reg9[5:4]
For CI3: BBBPPPPCCCC    BB: Reg10[2:0]
For CI4: BBBPPPPCCCC    BB: Reg10[5:3]

* Reg 0: Layer 0 priority (when enabled, see Reg 12)
* Reg 1: Layer 1 priority (when enabled, see Reg 12)
* Reg 2: Layer 2 priority (when enabled, see Reg 12)
* Reg 3: Layer 3 priority
* Reg 4: Layer 4 priority
* Reg 5: Bright priority threshold. When the winning layer's priority is equal or above this value, the BRIT output is set.
* Reg 6: Shadow priority when SDI inputs == 01
* Reg 7: Shadow priority when SDI inputs == 10
* Reg 8: Shadow priority when SDI inputs == 11

When SDI inputs == 0, shadow priority is set to lowest (111111)

* Reg 11:
** D0 low: Layer 0 transparency is color 0 of any palette
** D0 high: Layer 0 transparency is color 0 of palettes x0000
** D1 low: Layer 1 transparency is color 0 of any palette
** D1 high: Layer 1 transparency is color 0 of palettes x0000
** D2 low: Layer 2 transparency is color 0 of any palette
** D2 low: Layer 2 transparency is color 0 of palettes x0000
** D3 low: Layer 3 transparency is color 0 of any palette
** D3 low: Layer 3 transparency is color 0 of palette 0
** D4 low: Layer 4 transparency is color 0 of any palette
** D4 low: Layer 4 transparency is color 0 of palette 0
** D5: Swap Layers 0 and 1 ?

* Reg 12:
** D0 low: Layer 0 priority comes from PR0x inputs
** D0 high: Layer 0 priority comes from Reg 0
** D1 low: Layer 1 priority comes from PR1x inputs
** D1 high: Layer 1 priority comes from Reg 1
** D2 low: Layer 2 priority comes from PR2x inputs
** D2 high: Layer 2 priority comes from Reg 2
