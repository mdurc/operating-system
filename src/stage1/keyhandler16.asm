  [BITS 16]

  port60 dw 0 ; for storing scan code from port 60 as keyboard data

  ; ======================================

setup_keyhandler:
  cli ; clear interrupts
  mov bx, 0x09  ; keyboard hardware interrupt request (IRQ1)
  shl bx, 2     ; multiply by 4 to get index in IVT (Interrupt Vector Table)
  xor ax, ax
  mov gs, ax    ; gs = 0, pointing to IVT base address 0x0000:0x0000
  mov [gs:bx], WORD keyhandler  ; set low word (offset) of interrupt handler
  mov [gs:bx+2], ds             ; set high word (segment) of interrupt handler
  sti ; set interrupts
  ret

keyhandler:
  in al, 0x60           ; read scan code from keyboard data port 60
  mov bl, al            ; save in bl
  mov BYTE[port60], al  ; store scan code in variable port60

  in al, 0x61           ; read keyboard controller port
  mov ah, al
  or al, 0x80           ; set bit 7 to disable keyboard clock
  out 0x61, al          ; send it back
  xchg ah, al           ; swap ah and al
  out 0x61, al          ; restore original port value

  mov al, 0x20          ; send End of Interrupt (EOI) to PIC
  out 0x20, al

  and bl, 0x80          ; check if key released (bit 7 set)
  jnz keyhandler_done   ; if key released, skip printing

  mov ax, [port60]      ; load the scan code saved earlier
  mov  WORD[reg16], ax  ; setup hex print
  call hprint16
keyhandler_done:
  iret ; return from interrupt
