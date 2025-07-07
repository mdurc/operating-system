  ; The CPU starts in 16 bit real mode and the BIOS loads this code at address 0000:7c00.
  ; These addresses are in the form of 'segment:offset'.
  ; In real mode, addresses are calculated as segment * 16 + offset.
  ; This means that 0000:7C00 and 07C0:0000 are technically the same address.

  [ORG 0x7c00]  ; set the origin to the correct physical address, 0x0000:0x7C00
  [BITS 16]

  jmp start

  %include "print.inc"

start:
  ; 'cs' is the code segment where instructions live
  ; 'ds' is the data segment,
  ; 'ss' is the stack segment
  ; 'sp' is the stack pointer that grows downward in the segment of 'ss'
  ; 'es' is the extra segment for text video memory

  xor ax, ax
  mov ds, ax      ; set the data segment value to zero
  mov ss, ax      ; stack starts at 0
  mov sp, 0x9c00  ; 2000h past code start

  ; 0xb8000 physical address is the start of color text video memory
  mov ax, 0xb800  ; 16 * 0xb800 is the desired address
  mov es, ax

  cli ; clear interrupts
  mov bx, 0x09  ; keyboard hardware interrupt request (IRQ1)
  shl bx, 2     ; multiply by 4 to get index in IVT (Interrupt Vector Table)
  xor ax, ax
  mov gs, ax    ; gs = 0, pointing to IVT base address 0x0000:0x0000
  mov [gs:bx], WORD keyhandler  ; set low word (offset) of interrupt handler
  mov [gs:bx+2], ds             ; set high word (segment) of interrupt handler
  sti ; set interrupts

  jmp $ ; jump to current address (infinite loop)

keyhandler:
  in al, 0x60           ; read scan code from keyboard data port 60
  mov bl, al            ; save in bl
  mov BYTE[port60], al  ; store scan code in variable port60

  in al, 0x61   ; read keyboard controller port
  mov ah, al
  or al, 0x80   ; set bit 7 to disable keyboard clock
  out 0x61, al  ; send it back
  xchg ah, al   ; swap ah and al
  out 0x61, al  ; restore original port value

  mov al, 0x20  ; send End of Interrupt (EOI) to PIC
  out 0x20, al

  and bl, 0x80  ; check if key released (bit 7 set)
  jnz keyhandler_done      ; if key released, skip printing

  mov ax, [port60]      ; load the scan code saved earlier
  mov  WORD[reg16], ax  ; setup hex print
  call printreg16
keyhandler_done:
  iret ; return from interrupt

  port60 dw 0 ; for storing scan code from port 60 as keyboard data

  ; ===========

  ; $$ is the start address of the current segment
  ; $ is the current address
  ; $-$$ is the amount of bytes emitted so far in this segment
  ; we are filling up the remaining bytes with 0 to fulfill a 512 byte segment for BIOS
  times 510-($-$$) db 0

  ; in legacy bootloaders and qemu, this 0xAA55 boot signature is needed
  db 0x55
  db 0xAA
