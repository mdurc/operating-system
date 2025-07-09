  [BITS 64]
  %include "kernel/print64.asm"
  %define LINE_NUM 5
  %define ROW_OFFSET (LINE_NUM * 80 * 2 + 80 - 12)

kernel_entry:
  mov ax, DataSeg64
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax

  mov rsi, start_msg64
  mov dl, 0x1f
  call sprint64

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

  .halt: hlt
  jmp .halt
