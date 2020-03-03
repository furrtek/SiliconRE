# 86S100

Thanks to @Caiusarcade for donating the chip.

This custom chip is from Texas Instruments and serves as a dual 8-bit parallel-to-serial shift register with direction control and 2 data modes.

The schematic was traced from the chip's silicon and should represent exactly how it is internally constructed.

The CEDRIC cell just provides a logic low signal.

# Pinout

* Pin 1: Data mode select (2 x 8-step, or 4 x 4-step).
* Pin 2: Load/shift clock.
* Pin 3: High: load data on clock edge.
* Pin 4: Shift direction (horizontal flip).
* Pin 5: Overall horizontal flip setting ?
* Pin 6: High: set all outputs low.
* Pins 7 & 8: Group 2 outputs (4 x 4-step mode).
* Pins 9 & 10: Group 1 & 2 outputs (2 x 8-step mode).
* Pins 11~19: Group 2 data inputs.
* Pins 20~27: Group 1 data inputs.
* Pins 14 & 28: Ground and power.
