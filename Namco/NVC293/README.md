# NVC293

Fujitsu bipolar gate array from 1980. Implements a 6-bit wide, 3-stage shift register with output select and optional delay.

Donated by @MichelBee_.

# Pinout

 *1: Clock
 *8: Outputs delayed by one clock if high, immediate if low
 *10: Output stage select MSB (0: in, 1: in-1, 2: in-2, 3: in-3)
 *11: Output stage select LSB
 *7 -> 12
 *6 -> 13
 *5 -> 14
 *4 -> 15
 *3 -> 16
 *2 -> 17
 *9: Ground
 *18: VCC