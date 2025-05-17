# SiliconRE

Traces, schematics, and general infos about custom chips from the 80's and 90's, mostly video-game related, reverse-engineered from silicon die pictures.

Passion provides the energy, Patreon money provides the time https://www.patreon.com/furrtek :)

More of this from other people:
- https://github.com/ika-musume/ASIC_RE
- https://github.com/sergiopolog/GateArray-RE
- https://github.com/nukeykt/
- https://github.com/madoov/Custom_schematics
- https://github.com/BueniaDev/RakitaASIC
- https://www.patreon.com/skutis
- https://www.righto.com/
- https://siliconpr0n.org/

Chip database with references, date, manufacturers, silicon IDs, descriptions and donators (if in my collection): https://docs.google.com/spreadsheets/d/1-4YH3xBQobYJ0NR4TNJO10mzUCcyNdEzlFjsFldoQjc/edit?usp=sharing

Please reach out if you're working on any of these so I can update @'s and links. This kind of work can be very time consuming, it would be a shame if several people worked on the same chip without knowing (even though that could help cross-checking for errors).

# Cell lists

Check out `Cells` for cell lists and detailed traces for a few vendors. If you're reverse-engineering a gate array, this will save you a LOT of time.

# Die photos

Check out `Dies` for low-res photos of dies in my collection that I haven't scanned yet.

# Commissions

If you own some chips that need decapping and/or imaging, I may be able to get you x5 or x10 panoramas for free under these conditions:
* Chip must be from the 70's, 80's or early 90's. It's very unlikely that I'll be able to produce useful images for chips with datecodes above 1993, except if you don't need to see down to the transistors (ie check silicon markings, for the presence of memory blocks, etc...).
* Chip package must not be burnt or cracked. Untested or known non-functional is fine, as long as there are no evidences of severe silicon damage. Dirty package, bent/torn off pins, and cosmetic defects don't matter.
* Package must be plastic or ceramic with metal lid, through-hole or SMT doesn't matter.
* Failure is an option. Success rate is high but no guarantees. One sample is generally enough, two preferred.
* I can publish the pictures with a CC-BY license at any time. Your name can be listed as donator if you wish.
* No deadline (work will be done depending on my free time and on the weather where I live).
* No clueless, broke, or entitled freeloaders, nor posers intending on presenting my work as theirs. Anyone taking my generosity for granted will be bitten back (I have rabies).

If you have a specific deadline, I'll ask for financial participation depending on its tightness or reject the job if my schedule doesn't allow me to meet it.
If you need some reverse-engineering work done (schematics, verilog, partial or complete) on top of the decapping and imaging, we can discuss a price.

Please e-mail me at (nickname) @gmail.com .

# Projects statuses

* Done: Trace, schematic available. Verilog in some cases. Mistakes possible ! See issues.
* WIP: Work in progress.
* Embargo: Work done. Privately paid work that will be released in the future.
* Stalled: Some work done, can't do more right now.

|Company|Reference|Description|Status|
|-------|---------|-----------|------|
|Capcom |86S105|Sprite controller|Done|
|Capcom |86S100|Sprite graphics serializer|Done|
|Data East |VSC30|Idk lol but it's |Done|
|Hudson|BU5782K|PC-Engine GT I/O|Done|
|Hudson|uPD65005-195|PC-Engine multitap|Done|
|Konami|005885|Tilemap and sprite controller|Done|
|Konami|007121|Tilemap and sprite controller|Done|
|Konami|007232|PCM playback|Done|
|Konami|007452|Security|Done|
|Konami|007782|Timing generator|Done|
|Konami|051316|ROZ tilmap controller|Done|
|Konami|051937|Sprite graphics processor|Done|
|Konami|051960|Sprite controller|Done|
|Konami|053260|Tilemap graphics processor|Done|
|Konami|052109|Tilemap controller|Done|
|Konami|052591|Security|Done|
|Konami|053251|Graphics priority encoder|Done|
|Konami|053260|PCM playback and I/O|Done|
|Konami|053936|ROZ tilemap controller|Done|
|Konami|053990|Security/DMA|WIP|
|Konami|054321|Digital volume control and I/O|Embargo|
|Konami|054358|Security/DMA|WIP|
|Konami|055555|Layer mixer|WIP|
|Konami|056540|Voxel-like height processor|WIP|
|Namco|C102|ROZ tilemap memory I/O|Embargo|
|Namco|C106|Sprite scaling controller|Embargo|
|Namco|C120|Palette memory controller|Done|
|Namco|C134|Sprite controller|Embargo|
|Namco|C135|Sprite scanline matcher|Embargo|
|Namco|C137|Clock generator|Embargo|
|Namco|C146|Line buffer controller|Embargo|
|Namco|NVC293|Sprite graphics serializer|Done|
|Nintendo|MMC3B|Mapper|Done|
|Nintendo|MMC5|Mapper|WIP|
|Roland|R15229841|Chorus effect|WIP|
|Roland|R15229844|Reverb effect|WIP|
|Roland|RDD673106U|DEP-5 glue logic|Done|
|Sega|315-5218|PCM playback|Done|
|Sega|315-5242|Color encoder|Done|
|Sega|315-5248|Multiplier|Done|
|Seta|X1-004|Basic I/O|Done|
|Seta|X1-007|Palette controller, sync generator|Done|
|SNK|LSPC2-A2|Sprite controller|Done|
|SNK|NEO-273|Address latch|Done|
|SNK|NEO-BUF|Buffer duh|Done|
|SNK|NEO-B1|Line buffers|Done|
|SNK|NEO-C1|Glue logic|Done|
|SNK|NEO-D0|Clock generator, glue|Done|
|SNK|NEO-E0|Buffer, glue|Done|
|SNK|NEO-F0|Glue logic|Done|
|SNK|NEO-G0|Glue logic|Done|
|SNK|NEO-ZMC2|Z80 mapper, sprite graphics serializer|Done|
|SNK|PCM|PCM bus demux|Done|
|Taito|PC040DA|I forgot :(|Done|
|Taito|PC060HA|CPU I/O|Done|
|Thomson|EFGJ03L|MO5 main ASIC|Done|
|UMC|UM6618F|Super A'Can|Stalled|
|UMC|UM6619F|Super A'Can|Stalled|
