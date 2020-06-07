# 86S105

Thanks to @Caiusarcade for donating the chip.

* Role: Sprite parsing
* Manufacturer: Ricoh
* Die marking: © B5C39
* Technology: CMOS standard cell
* Used on: 1943, Ashita Tenki ni Naare, Black Tiger, Block Block, Capcom Baseball, Capcom World, Dokaben, Dokaben 2, Pang, Poker Ladies, Quiz Sangokushi, Quiz Tonosama no Yabou, Super Pang

# Operation

This chip has 3 internal RAM blocks:
* One 512-byte block is used as a buffer to store the attributes for a maximum of 128 sprites.
* Two 128-byte blocks are used as swappable active lists for a maximum of 32 sprites per scanline.

Each sprite has 4 attribute bytes defining its X and Y position, tile number, palette, flip bits...

Once per frame, the main CPU asks the 86S105 to pull the 512 bytes of sprite attributes it prepared in work RAM.
The 86S105 DMA-copies the data in its internal buffer. This allows sprite processing to occur without having to
share the work RAM and bother the CPU too much.

During scanline-2, the 128 sprite Y positions in the attributes buffer are scanned one by one.
Sprites which need to appear on scanline-0 have their 4 attribute bytes copied to the currently filled active list.
This process stops when the Y positions scan is done, or when the active list is full, whichever happens first.

During scanline-1, the previously filled active list is read back in sequence. Registers are used to present the attributes
on dedicated pins all at the same time. External circuitry then draws the sprite pixels in a line buffer.

(During scanline-0, the line buffer is shifted out to the display device.)

Both operations are done at the same time. While an active list is being filled, the other one is being read back.
They're swapped each new scanline.

# Pinout

See 86S105.ods
