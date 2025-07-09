  [BITS 64]
  %include "kernel/idt.asm"
  %include "kernel/isr.asm"
  %include "kernel/print64.asm"
  %define LINE_NUM 5
  %define ROW_OFFSET (LINE_NUM * 80 * 2 + 80 - 12)

  ticks_msg db "System timer ticks:", 0
  scancode_msg db "Keyboard scan code:", 0

kernel_entry:
  cli               ; no interrupts
  lidt [idt_descriptor]

  mov al, 0x80       ; OCW1: Unmask all interrupts at master PIC
  out PIC1_DATA, al
  mov al, 0x80       ; OCW1: Unmask all interrupts at master PIC
  out PIC2_DATA, al

  sti ; enable interrupts

  mov ax, DataSeg64
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax

  mov rsi, start_msg64
  mov dl, 0x1f
  call sprint64

  ;mov rax, 0x0020002000200020
  ;call fill_background

  ; access the color text video memory VRAM address
  mov edi, 0xb8000 + ROW_OFFSET

  ; store "hello kernel" in little endian to edi, in three chunks
  ; attribute 0x1F is a blue background for each char printed
  mov rax, 0x1f6c1f6c1f651f68
  mov [edi],rax
  mov rax, 0x1f651f6b1f201f6f
  mov [edi + 8], rax
  mov rax, 0x1f6c1f651f6e1f72
  mov [edi + 16], rax

  ;mov eax, 1
  ;mov ecx, 0
  ;div ecx

  ;.halt: hlt
  ;jmp .halt

  .loop:
  mov BYTE[ypos], 12
  mov rsi, ticks_msg
  mov dl, VGA_COLOR_LIGHT_GREEN
  call sprint64

  mov BYTE[ypos], 12
  mov [xpos], BYTE 21
  mov r8, QWORD[systimer_ticks]
  mov QWORD[reg64], r8
  call hprint64

  mov BYTE[ypos], 14
  mov rsi, scancode_msg
  mov dl, VGA_COLOR_LIGHT_CYAN
  call sprint64

  mov BYTE[ypos], 14
  mov [xpos], BYTE 21
  mov r8, QWORD[keyboard_scancode]
  mov QWORD[reg64], r8
  call hprint64
  jmp .loop
