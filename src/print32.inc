  ; ======================================
  ; 32 bit protected mode driver for printing the string's characters
sprint32:
  movzx eax, BYTE[esi]
  inc esi
  or al, al
  jz .finish_print
  call cprint32
  jmp sprint32
.finish_print:
  add BYTE[ypos], 1
  mov BYTE[xpos], 0
  ret

  ; 32 bit protected mode driver for drawing character in al to current position: (xpos, ypos)
cprint32:
  mov ah, 0x0f
  mov ecx, eax
  movzx eax, BYTE[ypos]
  mov edx, 160
  mul edx
  movzx ebx, BYTE[xpos]
  shl ebx, 1

  mov edi, 0xb8000      ; full address to start of video memory
  add edi, eax
  add edi, ebx

  mov eax, ecx
  mov WORD[ds:edi], ax  ; address is just from the offset in flat mode
  add BYTE[xpos], 1
  ret

  ; driver for printing 32 bit register (4 byte dword) in hex
hprint32:
  mov edi, outstr32
  mov eax, [reg32]
  mov esi, hexstr
  mov ecx, 8
.hexloop:
  rol eax, 4
  mov ebx, eax
  and ebx, 0x0f
  mov bl, [esi + ebx]
  mov [edi], bl
  inc edi
  dec ecx
  jnz .hexloop
  mov esi, outstr32
  call sprint32
  ret

  ; ======================================

  outstr32 db "00000000", 0     ; output of 4 byte dword
  reg32 dd 0                    ; 4 byte dword to print within hprint32

  start_msg32 db "--32 bit protected mode--", 0
