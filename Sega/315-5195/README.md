# Sega 315-5195

Memory mapper / CPU-Sub CPU-MCU interface

# Pinout

* A[23:1]: M68K address, bidirectional
* D[15:0]: M68K data, bidirectional
* RXW: M68K R/W input, bidirectional
* /RD: RXW inverted, internal signal during r/w operation
* /AS: M68K "address valid" input, bidirectional
* /BR: M68K bus request, open-collector output
* /BGACK: M68K bus ack, bidir fixed low output
* /DTACK (aka /KDAK): output to M68K /DTACK
* /EXACK (aka /EDAK): input from external perhipherals
* /VINT: M68K interrupt input
* /INT: MCU interrupt output
* /CS[7:0]: Decoded outputs
* /CRST: System reset

* AD[7:0]: MCU address/data bus (demux with ALE)
* /GACS: MCU chip select input
* ALE, /WRITE, /RD: MCU control signals

* PD[7:0]: Z80 data bus
* /PCS, /PRD, /PWR: Z80 control signals
* /PBF: Z80 interrupt output

* TEST normally high
* TESTG normally low

# Registers

* Reg0: Set D_LATCH[7:0] with MUX_IN_D
* Reg1: Set D_LATCH[15:8] with MUX_IN_D
* Reg2:
  * D[0]: M68K /RESET direction (1:In, reset state, forced output when /CRST is low)
  * D[1]: M68K /HALT direction (1:In, reset state, forced output when /CRST is low)
  * D[2]: M68K /BERR direction (1:In, reset state)
* Reg3: Load ->Z80 data latch (P bus output), triggers Z80 interrupt
* Reg4: M68K IPL lines:
  * D[2:0] M68K IPL lines
  * D[3]: Set pending interrupt ?
* Reg5: R/W operation control (setting both bits shouldn't do anything)
  * D[0]: Write
  * D[1]: Read
* Reg6:
  * D[0]: Enable MCU interrupt when data counter OVF
  * D[1]: Enable MCU interrupt when Z80 writes
  * D[2]: Enable continuous reading with address auto-inc
  * D[3]: Clear data counter OVF flag when low
* Reg7[6:0]: M68K address top bits for writes
* Reg8: M68K address middle bits for writes (affected by auto-inc)
* Reg9: M68K address middle bits for writes (affected by auto-inc)
* RegA[6:0]: M68K address top bits for reads
* RegB: M68K address middle bits for reads (affected by auto-inc)
* RegC: M68K address middle bits for reads (affected by auto-inc)
* RegD[3:0]: Data length bits[11:8] ? Is it 65535 - data length ?
* RegE: Data length bits[7:0] ? Is it 65535 - data length ?
* RegF[0]: Related to continuous read mode
* Reg10, 12... 1E:
  * [1:0]: Size mask for given region 0~7
  * [3:2]: /DTACK delay for given region 0~7
   * 0: Use /EDAK pin
   * 1~3: n cycles
* Reg11, 13... 1F: Base address for given region 0~7

* Z80 writes Z80-> data latch when /PCS and /PWR low
* Z80 reads ->Z80 data latch when /PCS and /PRD low

# Nets

* MUX_IN_D[7:0]: M68K D[7:0] or MCU AD[7:0] depending on MCU_MODE
* SUB_MAIN[7:0]: Z80 to M68K data latch
* PIN_AS_DIR: Low when r/w operation ongoing

# Notes

* MCU read xxx11: Acks Z80 write /INT
* MCU write reg6 D3: Clear data count-up /INT

MCU (AD bus) can read:
* 0: D_LATCH[15:8]
* 1: D_LATCH[7:0]
* 2: M68K control pin states / status
  * Bit 0: REST pin (active low)
  * Bit 1: HALT pin (active low)
  * Bit 2: BERR pin (active low)
  * Bit 3: IPL pins direction
  * Bit 4: IPL input related ?
  * Bit 5: Z80 interrupt pending
  * Bit 6: Busy with R/W operation (active low)
  * Bit 7: M68K interrupt pending ?
* 3: Z80-> latch data

It seems that after reset, the M68K has control of banking and r/w registers (MCU_MODE low, see K20).
As soon as the MCU performs a write, control is given to it forever until the next reset (MCU_MODE high).

The /CS outputs can only be active when there are no pending interrupts, and the external (M68K-driven) or internal (DMA-driven) /AS is active.

At startup, Reg4 has no effect. The only interrupt that can reach the M68K is from the /VINT input (IPL=011).
Once MCU_MODE is set, Reg4 becomes active and /VINT is ignored.
