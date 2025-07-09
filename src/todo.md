Stage 1:
- [x] Created 512-byte boot sector and set the boot signature
- [x] Write output with bios print
- [x] Add keyhandler to read input from the keyboard and output hex to screen
- [x] Use video memory to print while in real mode

Stage 2:
- [x] Load GDT and enter protected mode
- [x] Use video memory to print while in protected mode

Stage 3:
- [x] Set up a Page Map level 4 (PML4), Page Directory Pointer Table (PDPT), Page Directory (PD), and Page Table (PT) for identity mapping
- [x] Enable PAE
- [x] Load address of PML4 into CR3
- [x] Enable long mode bit
- [x] Set the PG (paging) bit
- [x] Jump to long mode using a far jump
- [x] Use video memory to print while in long mode

Stage 4:
- [ ] Setup a memory allocator in assembly
- [ ] Write drivers for keyboard input
- [ ] Write functions for terminal output using framebuffer or text mode
- [ ] Set up a basic kernel main function in long mode
- [ ] Implement a linker script for kernel and ensure it aligns with memory map
- [ ] Compile kernel to flat binary
- [ ] Modify bootloader to load the kernel binary from a known location on the disk
- [ ] Parse the kernel binary and copy it to the correct memory address
- [ ] Set up stack pointer for 64-bit kernel
- [ ] Jump to the kernel entry point in long mode
- [ ] Use kernel terminal output routine to print to the screen

Stage 5:
- [ ] Implement custom `x86_64` compiler support for kernel development
- [ ] Write a standard library using inline assembly?
- [ ] Use standard library function in my language to output to QEMU
