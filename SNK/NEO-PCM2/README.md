# NEO-PCM2

 * Manufacturer: Fujitsu
 * Type: Channelless gate array
 * Die markings: MBCG47153 TP2H94
 * Function: ADPCM ROM mux and decryption
 * Used in: NeoGeo cartridges

Package markings of specimen used: SNK NEO-PCM2 ©SNK 1999 0151 Z92

It is highly suspected that SNK 1999 and Playmore 2002 NEO-PCM2 chips are internally different due to the absence in the SNK version of any data XOR required by some later games.

# Jumper settings

Set means U, 1.

| Game | Type | JVU3 / Pin 62 | JVU2 / Pin 63 | JVU1 / Pin 64 | JU4 / Pin 65 | JU3 / Pin 66 | JU2 / Pin 67 | JU1 / Pin 68 | Data XOR
| ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| Matrimelee  | Playmore 02| Set|   set|   set|   reset| set|   set|   set|    yes
| Metal Slug 4| SNK 01|      Set|   set|   set|   reset| set|   set|   set|    no
| Metal Slug 5| Playmore 03| Set|   set|   set|   reset| reset| reset| reset|  yes
| Pochi & Nyaa| SNK 02|      Set|   reset| set|   reset| set|   set|   set|    no
| RotD        | SNK 99|      Set|   set|   set|   set|   set|   set|   set|    no
| SSV         | Playmore 03| Set|   set|   set|   set|   reset| set|   set|    yes
| SSVS        | Playmore 03| Set|   set|   set|   set|   reset| set|   set|    yes
| SVC         | Playmore 03| Set|   set|   set|   reset| reset| reset| reset|  yes
| Kof2001     | SNK 01|      Reset| reset| reset| reset| set|   set|   set|    no
| Kof2002     | Playmore 02| Set|   set|   set|   reset| set|   set|   set|    yes
| Kof2003     | Playmore 03| Set|   set|   set|   reset| reset| reset| reset|  yes

Standalone MVS boards which also use Playmore NEO-PCM2 also do a data XOR.
