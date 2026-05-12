  [BITS 64]
  DEFAULT REL

  ; Interrupt Service Routines

  systimer_ticks dq 0
  keyboard_scancode dq 0
  error_code_low dw 0
  error_code_high dw 0

  int_message db "Interrupt raised!", 0
  division_by_zero_message db "Division by zero!", 0
  gpf_message db "General Protection Fault!", 0
  pf_message db "Page Fault!", 0

  ; ======================================
ISR_dummy:
  cli
  push rax
  push r8
  push r9
  push rsi
  mov rsi, int_message
  mov dl, (VGA_COLOR_RED << 4) | VGA_COLOR_LIGHT_BROWN
  call sprint64
  pop rsi
  pop r9
  pop r8
  pop rax
  .halt: hlt
  jmp .halt
  iretq

ISR_div_by_zero:
  cli
  push rax
  push r8
  push r9
  push rsi
  mov rsi, division_by_zero_message
  mov dl, (VGA_COLOR_RED << 4) | VGA_COLOR_LIGHT_BROWN
  call sprint64
  pop rsi
  pop r9
  pop r8
  pop rax
  .halt: hlt
  jmp .halt
  iretq

ISR_gpf:
  cli
  push rax
  push r8
  push r9
  push rsi
  mov rsi, gpf_message
  mov dl, (VGA_COLOR_RED << 4) | VGA_COLOR_LIGHT_BROWN
  call sprint64
  pop rsi
  pop r9
  pop r8
  pop rax
  .halt: hlt
  jmp .halt
  iretq

ISR_page_fault:
  cli
  pop word [error_code_high]
  pop word [error_code_low]
  push rax
  push r8
  push r9
  push rsi
  mov rsi, pf_message
  mov dl, (VGA_COLOR_RED << 4) | VGA_COLOR_LIGHT_BROWN
  call sprint64
  pop rsi
  pop r9
  pop r8
  pop rax
  .halt: hlt
  jmp .halt
  iretq

ISR_systimer:
  push rax
  inc qword [systimer_ticks]
  mov al, PIC_EOI
  out PIC1_COMMAND, al
  pop rax
  iretq

ISR_keyboard:
  push rax
  xor rax, rax
  in al, 0x60
  mov [keyboard_scancode], al
  mov al, PIC_EOI
  out PIC1_COMMAND, al
  pop rax
  iretq

; al/rax <- current scancode
get_keyboard_scancode:
  xor rax, rax
  mov al, byte [keyboard_scancode]
  mov byte [keyboard_scancode], 0
  ret
