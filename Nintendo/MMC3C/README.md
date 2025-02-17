# Nintendo MMC3C

 * Manufacturer: NEC
 * Type: Gate array
 * Die markings: 91106
 * Die picture: https://siliconpr0n.org/map/nintendo/mmc3c/furrtek_mz/
 * Function: PRG and CHR ROM mapper, PRG RAM protection, scanline timer
 * Used in: A ton of NES games

M2 (Phi2) cleaning is a mess. Lots of delay cells involved.

# Registers

Matches everything found on [NESDev](https://wiki.nesdev.com/w/index.php/MMC3)
 
# Operation

The IRQ timer is ticked after PPU_A12 has been low for 3 falling edges of M2.
