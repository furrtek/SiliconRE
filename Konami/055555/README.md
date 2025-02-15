# Konami 055555 "PCU2"

 * Manufacturer: Fujitsu
 * Type: Gate array
 * Die markings: CG24173-610
 * Die picture: https://siliconpr0n.org/map/konami/055555/furrtek_mz/
 * Function: Video layer priority generator
 * Used in: Gaiapolis, Martial Champion, Metamorphic Force, Violent Storm
 * Chip donator: rep-arcade.com

Allows for 4 scroll layers, a sprite layer, and 3 sub layers. Shadow, brightness.
All registers are write-only.
Registers reset are COLCHG ON, DISP, BGC CBLK, BGC SET. Others are undefined.

Can select the number of color bits for each input layers: 4, 5, 6, 7, or 8.

Sprite layer inputs: 16 bits (8 palette + 8 color max). The palette bits (or O PRI register) are used as the priority code.

Sub 2/3 layer inputs: 13(10) color + 8 bits priority (or S2/S3 PRI register).

Scroll layer priority can be based on color code.

Palette RAM bank (0~7)*1024 can be set for each layer.

2-bit MIX code for alpha blending chip set for each layer, or external code.

2-bit BRIGHT code for alpha blending chip set for each layer, or external code (for sub and sprite layers only, not scroll).

2-bit SHADOW code stuff...

Background color palette RAM auto map H or V, 4-bit bank, 512 colors
