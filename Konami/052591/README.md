# Konami 052591 PMC

* Role: Custom CPU used for security through obscurity
* Manufacturer: Fujitsu
* Die marking: 660118
* Technology: CMOS gate array
* Used on: Hexion, Thunder Cross, S.P.Y.

Another one of Konami's crazy ideas to attempt thwarting piracy.

The 052591 is a custom 8/16 bit big-endian microprogrammed CPU.
* Eight 16-bit registers and one accumulator
* Single-step shift/rotate
* Add/sub and bitwise operations, no mul or div
* Parallel conditional branching based on 4 flags: zero, positive, and two others (todo)
* Access to a max of 8kB 8-bit external memory with independently controllable /OE and /WE lines
* All instructions take one cycle to execute. Accessing 16-bit external data must be done in two steps.

The game's main CPU loads a small program, gives it some data to process, lets it run, and gets interrupted when the results are ready.
Hexion has it connected to VRAM instead of dedicated work RAM ?

The program is stored in internal RAM, with a max size of 64 36-bit fixed-length instructions.

# Loading

Access to internal RAM and external data only works when the START pin is low.

The PC is set to DB[5:0] by writing with AB9 high and BK low. DB[7] locks(1) / unlocks(0) PC for program loading.
Loading a program is done in groups of 5 bytes, the least-significant one of each instruction first.
The instruction is stored and the PC is incremented on every 5th byte write.

External data can be loaded and read back when BK is high.
The internal RAM can't be read back. The BK pin has no effect on reads, external RAM will always be used.

# Instructions

Some of their bits have a single purpose, others are coded (see `instruction_bits.ods`).
Immediate values are 13-bit signed. Jumps are always absolute.

The MSB of the ALU A input is cleared when IR15=0 and IR35=1 (byte operation).
The external RAM address latch to PTR is updated when IR31=1 and IR30=0.
The OUT0 pin is set to IR16 when IR15=1 and IR34=0. It's set high after a reset.

PTR is ALU result or Reg A depending on IR[8:7]. Todo: Rename PTR to EXMUX (16-bit bus used for Ext RAM address or Ext RAM data with further high/low byte mux)

The ALU inputs are set according to IR[2:0]:
| IR[2:0] | A in    | B in  |
| ------- | ------- | ----- |
| 0       | Reg A   | Acc   |
| 1       | Reg A   | Reg B |
| 2       | 0       | Acc   |
| 3       | 0       | Reg B |
| 4       | 0       | Reg A |
| 5       | Imm/Ram | Reg A |
| 6       | Imm/Ram | Acc   |
| 7       | Imm/Ram | 0     |

Imm/Ram is immediate when IR35=1 and IR15=1, external RAM data otherwise.
Reg A is selected by IR[11:9], reg B by IR[14:12].

The ALU operation is defined by IR[5:3]. IR5 active low ALU output invert, IR4 ALU B input invert, IR3 ALU A input invert.
The OR operation has IR[5:3]=011, effectively doing ~(~A&~B). AND has IR[5:3]=100. 0, 1 and 2 enable arithmetic operations.
The result can be written to reg B, the accumulator, the external RAM address or data, all at the same time.

ALU inc when IR[33:32] == 01 and IR3=1.
ALU inc when IR[33:32] != 01 and IR34=1 and IR15=0.

Use `k052591_dec.py` to decode binary programs.

The schematic was traced from the chip's silicon and should represent exactly how it is internally constructed. The svg can be overlaid on the [die picture](https://siliconpr0n.org/map/konami/052591/furrtek_mz/).

![Konami 052591 internal routing](trace.png)
