# PC060HA 'CIU'

Thanks to @Ace646546 for donating a chip, and Caius for lending a board for verification.

This chip serves as a 4-bit communication interface between the main and sub CPUs. Both directions have four 4-bit register groups with half-full and full flags, along with NMI, MUTE and RESET control. Its functionality seems to be included in the later '''TC0140SYT''' chip.

According to MAME, it is used in the following Taito games:
* Asuka & Asuka
* Cameltry
* Champion Wrestler
* Daisenpu
* Darius
* Exzisus
* Fighting hawk
* Gokidetor
* Hit The Ice
* Master of Weapons
* Midnight Landing
* Operation Wolf
* Rainbow Islands
* Rastan
* Taito Bingo Wave
* Tetris
* Top Speed
* Violence Fight
* Volfied

The schematic was traced from the chip's silicon and should represent exactly how it is internally constructed.

![PC060HA internal routing](routing.png)
