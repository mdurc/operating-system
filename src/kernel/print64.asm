  [BITS 64]

  outstr64 db "0000000000000000", 0     ; output of 8 byte qword
  reg64 dq 0                            ; 8 byte qword to print within hprint64
  start_msg64 db "--64 bit long mode--", 0

  ; ======================================
  ; rsi <- address to 64 bit null-terminated string
  ; dl <- attribute
sprint64:
  movzx rax, BYTE[rsi]
  inc rsi
  or al, al
  jz .finish_print
  push rdx ; save attribute
  call cprint64
  pop rdx
  jmp sprint64
  .finish_print:
  add BYTE[ypos], 1
  mov BYTE[xpos], 0
  ret

  ; 64 bit long mode driver for drawing character in al to current position: (xpos, ypos)
  ; al <- character to print to video memory
  ; dl <- attribute
cprint64:
  mov ah, dl
  mov rcx, rax
  movzx rax, BYTE[ypos]
  mov rdx, 160
  mul rdx
  movzx rbx, BYTE[xpos]
  shl rbx, 1

  mov rdi, 0xb8000      ; full address to start of video memory
  add rdi, rax
  add rdi, rbx

  mov rax, rcx
  mov WORD[rdi], ax  ; address is just from the offset in flat mode
  add BYTE[xpos], 1
  ret

  ; driver for printing 64 bit register (8 byte qword) in hex
  ; outstr64 <- address to 64 bit null-terminated string
hprint64:
  mov rdi, outstr64
  mov rax, [reg64]
  mov rsi, hexstr
  mov rcx, 16
  .hexloop:
  rol rax, 4
  mov rbx, rax
  and rbx, 0x0f
  mov bl, [rsi + rbx]
  mov [rdi], bl
  inc rdi
  dec rcx
  jnz .hexloop
  mov rsi, outstr64
  call sprint64
  ret
