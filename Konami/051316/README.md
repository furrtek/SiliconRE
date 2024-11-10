# Konami 051316

 * Manufacturer: Fujitsu
 * Type: Channeled gate array with embedded RAM
 * Die markings: Z87160
 * Function: "PSAC" ROZ plane generator
 * Used in: ...

* CA0-3: XACC[14:11], pixel x in tile with optional flipping
* CA7-4: YACC[14:11], pixel y in tile with optional flipping
* CA15-8: RAM_R_D[7:0], tile code low
* CA23-16: RAM_L_D[7:0], tile code high

Logic for both counters is the same, except for trigger and mux signals of course.

# Registers

* 0-1: X start MSBs
* 2-3: X pixel inc
* 4-5: X line inc
* 6-7: Y start MSBs
* 8-9: Y pixel inc
* A-B: Y line inc
* C-D: ROM bank during test readout (bits [12:0])
* E:
  * Bit 0: Enable ROM readout (active low)
  * Bit 1: Enable tile X flip when tile code bit 14 is set
  * Bit 2: Enable tile Y flip when tile code bit 15 is set
  * Bit 3: Enable clock test output on OBLK pin
  * Bit 4-5: Internal clock select
  * Bit 6: Enable test mode (direct counter output on CA23-0, select which with bit 0)
  * Bit 7: Enable test mode (direct RAM output on CA23-16, select block with A10)
* F: Unmapped

# Pinout

* 1, 5, 6, 47, 49: NC
* 3, 16, 35, 48: GND
* 32, 64: VCC
* 2: 12MHz in
* 4: OBLK out (indicates that current pixel is out of plane)
* 7-15, 17-31: Graphics ROM address out
* 33: IOCS registers select
* 34: VRCS RAM select
* 36-46: CPU address in
* 50-57: CPU data in/out
* 58: CPU RW in
* 59: VSCN in (VBLANK active low)
* 60: HSCN in (HBLANK active low)
* 61: VRC in (VSYNC)
* 62: HRC in (HSYNC)
* 63: 6MHz in
