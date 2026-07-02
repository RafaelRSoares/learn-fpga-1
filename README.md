# All credit goes to Bruno Levy for his incredible work on making a tutorial explaining and teaching the use of FPGA and RISC-V

## This is merely a fork of Bruno's repository, focused on implementation of a riscv soc on a pynq-z2 board, and running a random forest on it

### Please first check out Bruno's repository (https://github.com/BrunoLevy/learn-fpga) for a more complete understanding of the matter, as this one is focused on running the soc on the pynq board and later running a random forest for the purpose of analizyng the timing and other measurements



# learn-fpga 
_Learning FPGA and RISC-V_ 

Mission statement: create teaching material for FPGAs, processor design and RISC-V, using around $40 per students.

![](FemtoRV/TUTORIALS/Images/IceStick_hello.gif)

FemtoRV: a minimalistic RISC-V CPU
----------------------------------- 
[FemtoRV](FemtoRV/README.md) is a minimalistic RISC-V design, with
easy-to-read Verilog sources directly written from the RISC-V specification. 
The most elementary version (quark), an RV32I core, weights 400 lines of VERILOG
(documented version), and 100 lines if you remove the comments. There
are also more elaborate versions, the biggest one (petitbateau) is an RV32IMFC
core. The repository also includes a companion SoC, with
drivers for an UART, a led matrix, a small OLED display, SPI RAM and
SDCard. Its most basic configuration fits on the Lattice IceStick (<
1280 LUTs). It can be used for teaching processor design and RISC-V
programming.



Links - Other FPGA resources
----------------------------
- [TinyPrograms](https://github.com/BrunoLevy/TinyPrograms) Tiny yet interesting C programs to play with your softcore
- [LiteX](https://github.com/enjoy-digital/litex) Framework in Amaranth (Python-based HDL) to build SOCs
- [Silice](https://github.com/sylefeb/Silice) A new HDL by my friend Sylvain Lefebvre
- [FuseSOC](https://github.com/olofk/fusesoc) and [Edalize](https://github.com/olofk/edalize), package manager and abstraction of FPGA tools
- [PipelineC](https://github.com/JulianKemmerer/PipelineC) Transform a C program into a pipelined specialized core !
- [ultraembedded](https://github.com/ultraembedded/) Amazing resources, [FatIOLib](https://github.com/ultraembedded/fat_io_lib),[ExactStep](https://github.com/ultraembedded/exactstep)...
- [picoRV](https://github.com/YosysHQ/picorv32) by Claire Wolf, my principal source of inspiration
- [VexRiscV](https://github.com/SpinalHDL/VexRiscv) and [NaxRiscV](https://github.com/SpinalHDL/NaxRiscv), performant and configurable pipelined and OoO cores, by Charles Papon, in SpinalHDL
- [SERV](https://github.com/olofk/serv) the tiniest RiscV core, with a bit-serial ALU
- [DarkRiscV](https://github.com/darklife/darkriscv) a simple pipelined core (written in one night according to the legend)
- [kianRiscV](https://github.com/splinedrive/kianRiscV) a simple yet complete Linux-capable core + soc
- [TinySys](https://github.com/ecilasun/tinysys/wiki) not that tiny SOC and OS
- [Will Green's project F](https://github.com/projf/projf-explore) tutorials with nice graphics effects
- [fpga4fun](https://www.fpga4fun.com/) learned there how to create VGA graphics
- [CoreScore](https://corescore.store/) how many cores can you fit on a FPGA ?
