  [BITS 16]
  %include "stage2/a20.asm"
  %include "stage2/gdt.asm"

  stage2_msg db "Stage 2 loaded!", 0
  longmode_not_supported_msg db "Long mode is not supported, halting", 0
  longmode_is_supported_msg db "Long mode is supported", 0

  ; Goal: is to enter long mode, https://wiki.osdev.org/Entering_Long_Mode_Directly
  ; it notes we should check that the CPU supports x86_64

stage2_entry:
  call enable_a20       ; will halt on failure

  cli                   ; no interrupts
  lgdt [gdt_descriptor] ; load the gdt register

  mov eax, cr0
  or eax, 1
  mov cr0, eax ; enable protected mode by setting cr0

  ; far jump to flush pipeline and enter 32-bit protected mode
  jmp 0x08:protected_mode_entry

  [BITS 32]
  %include "stage2/paging.asm"
  %include "stage2/pic.asm"
  %include "stage2/longmode.asm"
  %include "stage2/print32.asm"
protected_mode_entry:
  ; set data segment registers to 0x10 (data segment selector)
  mov ax, DataSeg32
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov esp, 0x9FC00  ; set up a protected mode stack

  mov esi, start_msg32
  call sprint32

  ; requires protected mode to be enabled here
  call is_longmode_supported
  jz .longmode_not_supported
  mov esi, longmode_is_supported_msg
  call sprint32

  ; now we can enter long mode
  call enable_paging
  call remap_pic
  call enter_longmode
  jmp .halt

  .longmode_not_supported:
  mov esi, longmode_not_supported_msg
  call sprint32

  .halt: hlt
  jmp .halt
