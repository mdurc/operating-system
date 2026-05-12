  [BITS 64]
  %include "kernel/asm/idt.asm"
  %include "kernel/asm/isr.asm"
  %include "kernel/asm/print64.asm"
  %define LINE_NUM 5
  %define ROW_OFFSET (LINE_NUM * 80 * 2 + 80 - 12)

  ticks_msg db "System timer ticks:", 0
  scancode_msg db "Keyboard scan code:", 0

kernel_entry:
  cli               ; no interrupts
  lidt [idt_descriptor]

  mov al, 0xFC       ; OCW1: Unmask IRQ0 (Timer) and IRQ1 (Keyboard)
  out PIC1_DATA, al
  mov al, 0xFF       ; OCW1: Mask all interrupts on slave PIC
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

  ; mov rax, 0x0020002000200020
  ; call fill_background

  ; print a 64 bit register
  mov rbx, 0xDEADBEEFCAFEC0DE
  mov [reg64], rbx
  call hprint64

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

  jmp _kernel_main ; function defined in mylang (prefex appended by compiler)

  .halt: hlt
  jmp .halt

; rdi <- port (16-bit)
; rsi <- value (8-bit)
outb:
  mov dx, di    ; Load port into dx
  mov ax, si    ; Load value into al
  out dx, al    ; Output byte in al to I/O port dx
  ret

; Taken from mylang compiler runtime asm:

; rdi <- dst
; rsi <- src
; rdx <- size
memcpy:
  mov rax, rdi
  mov rcx, rdx
  cld           ; clear direction flag
  rep movsb     ; copy rcx bytes (this clobbers rdi, rsi, and rcx)
  ret           ; rax holds original dst

; rdi <- dst
; rsi <- value
; rdx <- size
memset:
	mov r8, rdi
	mov rax, rsi
	mov rcx, rdx
	cld           ; clear direction flag
	rep stosb     ; fill memory (clobbers rdi and rcx)
	mov rax, r8   ; restore original dst
	ret
