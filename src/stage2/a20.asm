  [BITS 16]

  a20_enabled_msg db "A20 is enabled", 0
  a20_disabled_msg db "A20 is disabled", 0
  a20_trying_bios db "Trying to enable A20 with BIOS", 0
  a20_trying_keyb db "Trying to enable A20 with Keyboard Controller", 0
  a20_trying_io92 db "Trying to enable A20 with IO port 92", 0

enable_a20:
  call check_a20
  test ax, ax
  jnz .done

  ; try to enable using BIOS
  mov si, a20_trying_bios
  call sprint16
  call enable_a20_bios

  call check_a20
  test ax, ax
  jnz .done

  ; try to enable using keyboard controller
  mov si, a20_trying_keyb
  call sprint16
  call enable_a20_keyb

  call check_a20
  test ax, ax
  jnz .done

  ; try to enable using keyboard controller
  mov si, a20_trying_io92
  call sprint16
  call enable_a20_io92

  call check_a20
  test ax, ax
  jnz .done

  .halt: hlt
  jmp .halt

  .done:
  ret

  ; https://wiki.osdev.org/A20_Line#Testing_the_A20_line
  ; ax -> 0 if a20 line is disabled, 1 if enabled
check_a20:
  call .test_a20
  test ax, ax
  jnz .a20_enabled
  mov si, a20_disabled_msg
  call sprint16
  ret
  .a20_enabled:
  mov si, a20_enabled_msg
  call sprint16
  ret

  .test_a20:
  pushf
  push ds
  push es
  push di
  push si
  cli

  xor ax, ax ; ax = 0
  mov es, ax
  not ax ; ax = 0xFFFF
  mov ds, ax

  mov di, 0x0500 ; these two values are guaranteed to be free
  mov si, 0x0510

  ; save the original values found at the addresses
  mov al, BYTE[es:di]
  push ax

  mov al, BYTE[ds:si]
  push ax

  mov BYTE[es:di], 0x00 ; [es:di] is 0:0500
  mov BYTE[ds:si], 0xFF ; [ds:si] is FFFF:0510

  cmp BYTE[es:di], 0xFF ; if the A20 line is disabled, [es:di] will contain 0xFF
  ; (as the write to [ds:si] really occured to 00500).

  pop ax
  mov BYTE[ds:si], al

  pop ax
  mov BYTE[es:di], al

  ; disabled
  mov ax, 0
  je .done

  ; enabled
  mov ax, 1
  .done:
  pop si
  pop di
  pop es
  pop ds
  popf
  ret

  ; uses INT 15
enable_a20_bios:
  mov ax, 0x2403    ; Query A20 gate support
  int 0x15
  jb .done          ; failure: INT 15h is not supported
  cmp ah, 0
  jnz .done         ; failure: INT 15h is not supported

  mov ax, 0x2402    ; Get A20 gate status
  int 0x15
  jb .done          ; failure: couldn't get status
  cmp ah, 0
  jnz .done         ; failure: couldn't get status

  cmp al, 1
  jz .done          ; success: A20 is already activated

  mov ax, 0x2401    ; Enable A20 gate
  int 0x15
  jb .done          ; failure: couldn't enable the gate
  cmp ah,0
  jnz .done         ; failure: couldn't enable the gate

  .done:
  ret

  ; using the Keyboard Controller chip (8042 chip)
enable_a20_keyb:
  cli

  call .a20wait
  mov al, 0xAD  ; disable keyboard
  out 0x64, al

  call .a20wait
  mov al, 0xD0  ; read output port
  out 0x64, al

  call .a20wait2
  in al, 0x60   ; read output port data
  push ax

  call .a20wait
  mov al, 0xD1  ; write output port
  out 0x64, al

  call .a20wait
  pop ax
  or al, 2
  out 0x60, al

  call .a20wait
  mov al, 0xAE  ; enable keyboard
  out 0x64, al

  call .a20wait
  sti
  ret

  .a20wait:
  in al, 0x64
  test al, 2
  jnz .a20wait
  ret


  .a20wait2:
  in al, 0x64
  test al, 1
  jz .a20wait2
  ret

  ; Fast A20 Gate
enable_a20_io92:
  in al, 0x92
  test al, 2
  jnz .done
  or al, 2
  and al, 0xFE
  out 0x92, al
  .done:
  ret
