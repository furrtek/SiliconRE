# Konami 053252

 * Manufacturer: Oki
 * Type: Channeled gate array
 * Die markings: 7012V010
 * Die picture: https://siliconpr0n.org/map/konami/053252/furrtek_mz/
 * Function: Video interrupt generator
 * Used in: Racing Force, X-Men, Run and gun
 * Chip donator: @Ace646546 and CaiusArcade

# Pinout

See `053252_pinout.ods`

* NHBS: NHBK delayed by 1~8 K42 clocks, selected by register $6.
* SEL[1:0]: Selects CRES delay and internal CLKSEL source.
  * 00: CLKSEL = PIN_CLK2	CRES = A38_Q1 (2 frames)
  * 01: CLKSEL = PIN_CLK1	CRES = A38_Q3 (4 frames)
  * 10: CLKSEL = PIN_CLK	CRES = A61_Q3 (8 frames)
  * 11: CLKSEL = 0          CRES = 0
* SEL2: 0:Internal H/Vsync, 1:External H/Vsync through HLD1 and VLD1 pins.
* CRES: RES delayed by a programmable number of frames.

The H counter (pixels) is 10-bit. The V counter (lines) is 9-bit. The frame counter is 2-bit.

INT1 is a frame interrupt, INT2 is a configurable line match interrupt.

* Counter A is used to time Vsync end to vblank end.
* Counter B is used to time Hsync end to hblank end.
* Counter C is used for ?
* Counter D is used for the line match interrupt.

# Registers

There are 16 write-only, and 2 read-only registers. Many go in pairs to form big-endian values.

Write:
* 0: [1:0]: H counter max upper bits, set on reset
* 1: [7:0]: H counter max lower bits, cleared on reset
* 2: [0]: H counter compare upper bit, hblank start, cleared on reset
* 3: [7:0]: H counter compare lower bits, hblank start, cleared on reset
* 4: [0]: Counter B upper bit, hsync length, set on reset
* 5: [7:0]: Counter B lower bits, hsync length, cleared on reset
* 6: [2:0]: NHBS pin delay select, cleared on reset
* 7: [7]: disable counters ?, [1]: Enable frame counter, [0]: Select frame counter bit for FCNT output pin, cleared on reset
* 8: [0]: V counter max upper bit, set on reset
* 9: [7:0]: V counter max lower bits, cleared on reset
* 10: [7:0]: V counter compare value, vblank start, cleared on reset
* 11: [7:0]: Counter A load value, vsync length, cleared on reset
* 12: [7:0]: Counter C load value, cleared on reset
* 13: [7:0]: Counter D (line interrupt counter) load value, writing enables counter and therefore INT2, undefined on reset
* 14: Clears INT1 (frame interrupt)
* 15: Clears INT2 (line match interrupt)

Read: V counter
* 14: {VCNT[7:1], VCNT[8]}
* 15: VCNT[7:0]

# Example data

Metamorphic Force sets up things in following way.

* SEL[2:0] = 0 (24MHz / 4 = 6MHz pixel clock, one pixel = 167ns)
* HLD1 = VLD1 = 1

Registers:
* 0: $01
* 1: $7F H counter reload = $17F (one line is 384 pixels)
* 2: $00
* 3: $11 H counter compare = $011 (hblank starts 18 pixels before hsync)
* 4: $00
* 5: $27 Counter B reload = $27 (hsync lasts 40 pixels)
* 6: $01 NHBS delay = 2 pixels
* 9: $07 V counter reload = $107 (register 8 is set on system reset) (one frame is 264 lines)
* 10: $10 V counter compare = $10 (vblank starts 16 lines before vsync)
* 11: $0F Counter A reload = $0F
* 12: $74 Counter C reload = $74 (what's this ?)

Register 7 is left cleared so the frame counter isn't used, FCNT stays low.

Register 13 isn't set so INT2 is disabled.

Register 14 is written to each frame (INT1 acknowledge).

This configuration produces the following signal timings:

* NHSY: 6.7us low (40 pixels), 57.3us high (344 pixels) (64us total, 384 pixels)
* NHBK: 16us low (96 pixels), 48us high (288 pixels) (64us total, 384 pixels)
* NVSY: 512us low (8 lines), 16.4ms high (256 lines) (16.9us total, 264 lines)
* NVBK: 2.56ms low (40 lines), 14.3ms high (224 lines) (16.9us total, 264 lines)

* NHLD: 166ns low, 64us high (one pixel low out of 384 pixels)
* NVLD: 166ns low, 16.9ms high (one pixel low out of 264 lines)

# Schematic

The schematic was traced from the chip's silicon and should represent exactly how it is internally constructed. The svg can be overlaid on the die picture.

![Konami 053252 internal routing](routing.png)
