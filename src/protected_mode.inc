  ; enable A20 Line
  in al, 0x92
  or al, 0x02
  out 0x92, al

  cli                   ; no interrupts
  lgdt [gdt_descriptor] ; load the gdt register

  ; enter protected mode by setting cr0
  mov eax, cr0
  or eax, 1
  mov cr0, eax

  ; far jump to flush pipeline and enter 32-bit protected mode
  jmp 0x08:protected_mode_entry

  ; enter 32 bit protected mode
  [BITS 32]
  %include "print32.inc"
protected_mode_entry:
  ; set data segment registers to 0x10 (data segment selector)
  mov ax, 0x10
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov esp, 0x9FC00  ; set up a protected mode stack

  mov esi, start_msg32
  call sprint32

  jmp $

gdt_descriptor:
  dw gdt_end - gdt_start - 1  ; GDT size (limit)
  dd gdt_start                ; GDT base address

gdt_start:
  ; Null Descriptor (selector 0x00)
  dd 0, 0

  ; Code Segment Descriptor (selector 0x08)
  dw 0xFFFF     ; Limit (low bits)
  dw 0x0000     ; Base (low bits)
  db 0x00       ; Base (middle bits)
  db 0x9A       ; Access Byte
  db 0xCF       ; Granularity and Limit (high bits)
  db 0x00       ; Base (high bits)

  ; Data Segment Descriptor (selector 0x10)
  dw 0xFFFF, 0x0000
  db 0x00, 0x92, 0xCF, 0x00
gdt_end:
