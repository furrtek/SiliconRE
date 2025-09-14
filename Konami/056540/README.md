# Konami 056540

 * Manufacturer: Toshiba
 * Type: ?
 * Die markings: ?
 * Function: "PSAC4"
 * Used in: Racin' Force, Konami's Open Golf Championship
 
A voxel-like terrain height processor. Currently unsupported in MAME.

 * Supports 8bpp colors max.
 * Uses 2kx8 of external SRAM "LRAM" (EXCGAB[10:0]/LA[10:0], EXCGDB[7:0]/LD[7:0]) which might be internally copied by DMA. Maybe used as tile attributes for PR[7:0] output ?
 * Uses a pair of external 512x512x8x3 DRAM groups A and B, each with a common address bus FAx[8:0], and separate C, P and H data busses. Not enough for framebuffers given the color depth.
 * Unclear if there are internal registers, no obvious CPU access except maybe through LA/LD with RCS active ?
 * HD[7:0]: from SRAMs or (control by HBEN) formed by selected bits from the HDB 24 (3 ROMs) or 32 (4 ROMs) bit HROM data bus. Selection by HA[1:0] (4 pixels / word). Height data ?
 * CI[7:0]: formed by selected bits from the CDB 24 (3 ROMs) or 32 (4 ROMs) bit CROM data bus. Selection by CA[1:0] (4 pixels / word). Color data ?
 * HROM and CROM address from 053936 X/Y coords, from which the lower 4 bits are flippable (16x16 tiles), the higher bits are looked up sequentially from SRAMs.
 * CO[7:0] and PR[7:0] are used to address palette RAM.
 
 Racin' Force uses 6bpp CROM and HROM data.
 
