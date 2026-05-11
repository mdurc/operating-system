x86_64 OS
* boots from the hardware, establishes virtual memory, configures interrupts, passes control to higher level kernel written in `mylang`
* mylang is a custom language I made that is compiled into freestanding x86_64 assembly, `.sn` file extension

stage1: boot16
* 16-bit real mode bootloader (1MB memory limit)
* BIOS loads 512b from sector 0 into memory address 0x7c00
  * verifies 0xAA55 signature at the end of the 512 bytes
* loads stage2 from disk and preps for mode switching

stage2: boot32
* 32-bit protected mode
* handles transition into 64-bit long mode (paging, A20 line, CPUID checks)
  * enables A20 line
  * load 32-bit GDT
  * setup paging and virtual memory to perform a far jump into 64-bit segment
  * enable PAE/PG bits

kernel64
* 64-bit long mode kernel
* handles the IDT, hardware interrupts, bridge to higher level entrypoint within `kernel_entry.sn`
* mylang handles kernel logic...
  * compiled with --freestanding flag:
     Skip any runtime injection of macos/linux syscalls into the generated x86_64 assembly.
     No _start wrapper, avoiding os-specific entrypoint.
     Drops .data/.bss section directives so that NASM treats the output as a single, contiguous block of machine code.
  * os.asm `%includes`s the generated mylang assembly file, and `kernel.asm` will jump to it via `call _kernel_main`.
     Mylang functions are prefixed by an underscore in the generated assembly.
  * hardware is controlled by casting integer physical addresses to typed pointers (`mut vga := cast<ptr<mut u16>>(753664);`), and inline `asm {}` blocks are used to issue raw hardware commands (like `hlt` or Port I/O) without dropping out of the language.


Stage 1:
- [x] Created 512-byte boot sector and set the boot signature
- [x] Write output with bios print
- [x] Add keyhandler to read input from the keyboard and output hex to screen
- [x] Use video memory to print while in real mode

Stage 2:
- [x] Load GDT and enter protected mode
    - [x] Create 32 bit and 64 bit code and data segment locations (note that we need both because we are going to be running code in 32 bit protected mode, despite that not being strictly necessary)
- [x] Use video memory to print while in protected mode

Stage 3:
- [x] Set up a Page Map level 4 (PML4), Page Directory Pointer Table (PDPT), Page Directory (PD), and Page Table (PT) for identity mapping
- [x] Enable PAE
- [x] Load address of PML4 into CR3
- [x] Enable long mode bit
- [x] Set the PG (paging) bit
- [x] Remap PIC for hardware interrupts (may be unecessary in the future)
- [x] Jump to long mode using a far jump
- [x] Use video memory to print while in long mode

Stage 4:
- [x] Implement `--freestanding` flag in mylang compiler.
- [x] Strip OS-dependent system calls, runtime assembly, and section headers from compiler output.
- [x] Set up Makefile to compile `.sn` to `.asm` and stitch into flat `os.bin`.
- [x] Use mylang pointers to interface directly with physical VGA memory.

TODO:
- [ ] Parse basic memory map from BIOS/UEFI (e820) to find usable RAM.
- [ ] Initialize a Physical Memory Manager to hand out 4KB page frames.
- [ ] Initialize a Virtual Memory Manager to map new pages dynamically.
- [ ] Build a custom Heap Allocator in mylang.
- [ ] Build a basic process scheduler (round-robin or similar).
- [ ] Implement context switching and standard threading.
