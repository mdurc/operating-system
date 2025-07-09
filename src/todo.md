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
- [x] Remap 
- [x] Jump to long mode using a far jump
- [x] Use video memory to print while in long mode

Stage 4:
- Set up IDT for interrupt handling
- Initialize interrupt controller (PIC/APIC).
    - Enable interrupts (sti).
- Set up a basic memory map from BIOS/UEFI (use multiboot/e820 if needed).
- Initialize physical memory manager (bitmap or buddy allocator).
- Initialize virtual memory manager (paging structures).
- Set up a basic heap allocator.
- Implement a basic kernel printf/debug output.
- Set up keyboard input handler.
- Implement timer interrupt (PIT or HPET).
- Build basic scheduler (round-robin or similar).
- Initialize file system drivers or bootfs.
- Load and execute init process or shell.
- Add syscall interface (using syscall/sysret).
- Set up user-space memory layout.
- Switch to user mode and run user code.
- Implement context switching.
- Add basic process and thread management.
- Implement standard libraries and runtime support.

Stage 5:
- [ ] Implement custom `x86_64` compiler support for kernel development
- [ ] Write a standard library using inline assembly?
- [ ] Use standard library function in my language to output to QEMU
