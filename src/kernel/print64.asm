  [BITS 64]

  hex_prefix db "0x", 0
  outstr64 db "0000000000000000", 0   ; output of 8 byte qword
  reg64 dq 0                          ; 8 byte qword to print within hprint64
  start_msg64 db "--64 bit long mode--", 0

  VGA_WIDTH equ 80
  VGA_HEIGHT equ 25
  VGA_COLOR_BLACK equ 0
  VGA_COLOR_BLUE equ 1
  VGA_COLOR_GREEN equ 2
  VGA_COLOR_CYAN equ 3
  VGA_COLOR_RED equ 4
  VGA_COLOR_MAGENTA equ 5
  VGA_COLOR_BROWN equ 6
  VGA_COLOR_LIGHT_GREY equ 7
  VGA_COLOR_DARK_GREY equ 8
  VGA_COLOR_LIGHT_BLUE equ 9
  VGA_COLOR_LIGHT_GREEN equ 10
  VGA_COLOR_LIGHT_CYAN equ 11
  VGA_COLOR_LIGHT_RED equ 12
  VGA_COLOR_LIGHT_MAGENTA equ 13
  VGA_COLOR_LIGHT_BROWN equ 14
  VGA_COLOR_WHITE equ 15

  ; 64 bit video graphics driver
  ; ======================================
  ; rax <- (XY ZZ XY ZZ XY ZZ XY ZZ),
  ; X is 4 bit background color,
  ; Y is 4 bit character color,
  ; ZZ is ascii code byte of character to fill the screen with
fill_background:
  mov rdi, 0xb8000
  ; each screen cell is 2 bytes (char + attrib),
  ; so the total size is actually width*height*2,
  ; but since we are storing qwords of data,
  ; we only need to do width*height*2/8 total writes
  mov rcx, VGA_WIDTH * VGA_HEIGHT / 4
  ; rax is the value to store
  ; rdi is the destination address
  ; rcx is the number of qwords to store
  rep stosq
  ret


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
  mov rdx, VGA_WIDTH * 2  ; 2 bytes per cell
  mul rdx
  movzx rbx, BYTE[xpos]
  shl rbx, 1

  mov rdi, 0xb8000        ; full address to start of video memory
  add rdi, rax
  add rdi, rbx

  mov rax, rcx
  mov WORD[rdi], ax       ; address is just from the offset in flat mode
  add BYTE[xpos], 1
  ret

  ; driver for printing 64 bit register (8 byte qword) in hex
  ; outstr64 <- address to 64 bit null-terminated string
hprint64:
  mov r8b, [xpos]
  mov r9b, [ypos]
  mov rsi, hex_prefix
  call sprint64
  mov [ypos], r9b
  add r8b, 2 ; move forward to account for printing "0x"
  mov [xpos], r8b

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
