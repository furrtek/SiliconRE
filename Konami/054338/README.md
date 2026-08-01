# Konami 054338

 * Manufacturer: Fujitsu
 * Type: Channeled gate array
 * Die markings: CG10572-113
 * Die picture: Unavailable
 * Function: Color math
 * Used in: Bucky 'O Hare, Cowboys of Moo Mesa, Martial Champion, Metamorphic Force, Violent Storm, XEXEX
 * Chip donator: @CaiusArcade

Two layer fading / alpha blending and palette RAM arbiter chip. Takes in alternating pixel color codes for the two layers, a transparency flag, a mixing code, a shadow code, and a brightness code.
Outputs 8-bit RGB and overall brightness values which are fed to DACs.

# Registers

No DTACK delay for register access. Registers are word wide.

* Reg 0:
  * [7:0]: Background red
* Reg 1:
  * [15:8]: Background green
  * [7:0]: Background blue
* Reg 2:
  * [8:0]: Shadow code 1 red
* Reg 3:
  * [8:0]: Shadow code 1 green
* Reg 4:
  * [8:0]: Shadow code 1 blue
* Reg 5:
  * [8:0]: Shadow code 2 red
* Reg 6:
  * [8:0]: Shadow code 2 green
* Reg 7:
  * [8:0]: Shadow code 2 blue
* Reg 8:
  * [8:0]: Shadow code 3 red
* Reg 9:
  * [8:0]: Shadow code 3 green
* Reg 10:
  * [8:0]: Shadow code 3 blue
* Reg 11:
  * [7:0]: Brightness code 1 value
* Reg 12:
  * [15:8]: Brightness code 2 value
  * [7:0]: Brightness code 3 value
* Reg 13:
  * [5]: Mix code 1 mode
  * [4:0] Mix code 1 level
* Reg 14:
  * [13]: Mix code 2 mode
  * [12:8] Mix code 2 level
  * [5]: Mix code 3 mode
  * [4:0] Mix code 3 level
* Reg 15:
  * [0]: Enables layers, 0 forces background color
  * [1]: Select MIX pins input delay
  * [2]: Select SHD pins input delay
  * [3]: Select BRI pins input delay
  * [4]: CPU access priority
  * [5]: Disable output min/max clamping

Mode 0 is alpha blending (interpolation between layers, point set by level), mode 1 is addition (layer A + layer B * (32 - level)).

The alpha blending is an 8 by 5 bit pipelined combinational multiply and add operation, the top 8 bits of the 14 bit result are used.

The shadow operation is actually a shadow/highlight done as a final addition, the 9 bit level value for each component is signed (0 is normal, -255 is zero, +255 is max).

The brightness values are completely independent from color, they're used to scale the RGB outputs in the analog domain.

# Palette RAM access

No DTACK delay in blanking.
DTACK delay possible during display, depends on which slot the access falls into and if MIX code is non-zero (alpha blending enabled).
