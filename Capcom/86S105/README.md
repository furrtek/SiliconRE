# Capcom 86S105

Thanks to @Caiusarcade for donating the chip.

* Role: Sprite parsing
* Manufacturer: Ricoh
* Die marking: © B5C39
* Technology: CMOS standard cell
* Used on: 1943, Ashita Tenki ni Naare, Black Tiger, Block Block, Capcom Baseball, Capcom World, Dokaben, Dokaben 2, Pang, Poker Ladies, Quiz Sangokushi, Quiz Tonosama no Yabou, Super Pang

Very similar logic can be found implemented with discrete logic chips on Ghosts and Goblins (schematics pages 11 to 13).

# Operation

This chip has 3 internal RAM blocks:
* One 512-byte block is used as a buffer to store the attributes for a maximum of 128 sprites per frame.
* Two 128-byte blocks are used as a pair of active lists for a maximum of 32 sprites per scanline.

Each sprite has 4 parameter bytes:
* Tile number, which can be extended by some of the attribute bits, depending on external wiring.
* Attributes, the purpose of each bit is defined externally. At least some bits are used for the palette number.
* Vertical (Y) position.
* Horizontal (X) position.

Once per frame, the main CPU asserts the /RDY line, asking the 86S105 to pull 512 bytes of sprite parameters it prepared in work RAM.
The 86S105 does a DMA copy of the data in its internal buffer. This allows sprite processing to occur during the frame without having to
share the work RAM accesses with the CPU.

During scanline-2, the 128 sprite Y positions in the internal buffer are scanned one by one.
Sprites which are determined to appear on scanline-0 have their 4 parameter bytes copied to the active list currently being filled.
This process stops when all 128 Y positions have been scanned, or when the active list is full, whichever happens first.

During scanline-1, the data from the previously filled active list is read back in sequence. Parallel registers are used to present
all the parameters on dedicated pins at the same time. External circuitry then draws the sprite pixels in line buffers, which are
finally shifted out to the display during scanline-0.

Both Y scanning and active list reading operations are done at the same time. While an active list is being filled, the other one is
used for output. They're swapped each new scanline.

# Pinout

See `86S105_pinout.ods`
