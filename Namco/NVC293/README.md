# Namco NVC293

 * Manufacturer: Fujitsu
 * Type: Bipolar array
 * Die markings: 293-1
 * Die picture: https://siliconpr0n.org/map/namco/nvc293/furrtek_mz/
 * Function: ?
 * Used in: Rally-X
 * Chip donator: @MichelBee_

Implements a 6-bit wide, 3-stage shift register with output select and optional delay.

# Pinout

 * 1: Clock
 * 2 -> 17
 * 3 -> 16
 * 4 -> 15
 * 5 -> 14
 * 6 -> 13
 * 7 -> 12
 * 8: Outputs delayed by one clock if high, immediate if low
 * 9: Ground
 * 10: Output stage select MSB (0: in, 1: in-1, 2: in-2, 3: in-3)
 * 11: Output stage select LSB
 * 18: VCC
