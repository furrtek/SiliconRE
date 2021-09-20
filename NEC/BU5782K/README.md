# Rohm BU5782K

Chip donated by @tailchao.

Tiny gate array found on the input board of the NEC PC-Engine GT. Handles inputs multiplexing, link I/O and the sleep function.

Uses its own RC oscillator to run the sleep timer, which is reset by pressing any of the 8 buttons. The timeout is set externally by R800, R801 and C801.

The input section is identical to what's found in regular PC-Engine joypads.

Link inputs are read via bits 0 and 1 of $1000 while CLR is high.