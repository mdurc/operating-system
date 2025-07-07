  ; driver for printing the string's characters
dochar:
  call cprint         ; print the char and fallthrough to sprint
sprint:
  lodsb               ; load and inc: mov al, [si] ; inc si
  or al, al
  jnz dochar          ; if it is not a null-byte, then print the char
  ; else we have finished the string (reached the null-byte)
  add BYTE[ypos], 1  ; move the cursor down one row
  mov BYTE[xpos], 0  ; reset to first column
  ret

  ; draw character in al to current position: (xpos, ypos)
cprint:
  mov ah, 0x0f          ; attrib = white on black
  ; now ax is the char in lower byte and attrib in upper
  mov cx, ax            ; save ax in cx

  movzx ax, BYTE[ypos]  ; ax = y position
  mov dx, 160           ; 80 cols * 2 bytes per char = 160
  mul dx                ; ax = ax * 160 = byte offset to row

  movzx bx, BYTE[xpos]  ; bx = x position
  shl bx, 1             ; times 2 (char + attrib = 2 bytes)

  mov di, 0           ; start of video memory
  add di, ax          ; add y offset
  add di, bx          ; add x offset

  mov ax, cx          ; restore char/attribute
  stosw               ; store ax at [es:di], and increment di by 2 bytes (write char/attribute)
  add BYTE[xpos], 1   ; move cursor to the right for the next char
  ret

  ; ======================================

  ; driver for printing reg16 (2 byte word) in hex
printreg16:
  mov di, outstr16
  mov ax, [reg16]
  mov si, hexstr
  mov cx, 4         ; we will be printing 4 hex digits (2 bytes : reg16)
hexloop:
  rol ax, 4         ; Rotate left by 4 bits to bring the leftmost to rightmost
  mov bx, ax        ; copy to bx
  and bx, 0x0f      ; extract the 4 bit nibble
  mov bl, [si + bx] ; load the ascii hex character for that digit
  mov [di], bl      ; store that character in the output string
  inc di            ; go to the next byte address of the output string
  dec cx
  jnz hexloop
  ; print out the hex string and return
  mov si, outstr16
  call sprint
  ret

; Only works in real mode (not protected/long mode)
; Not available once BIOS interrupts are no longer accessible
bios_print:
  lodsb               ; Load and inc: mov al, [si] ; inc si
  or al, al           ; check if we reached the null-byte of the string
  jz bios_print_done  ; exit if so
  mov ah, 0x0E        ; high byte of ax to BIOS function 0x0E = Teletype output
  mov bh, 0           ; high byte of bx
  int 0x10            ; call interrupt to bios video services
  jmp bios_print
bios_print_done:
  ret

  ; ======================================

  ; x and y coordinates to print characters to
  xpos db 0
  ypos db 0
  hexstr db "0123456789ABCDEF"  ; hex digits lookup table
  outstr16 db "0000", 0         ; output of 2 byte word
  reg16 dw 0                    ; 2 byte word to print within printreg16
