  ; The CPU starts in 16 bit real mode and the BIOS loads this code at address 0000:7c00.
  ; These addresses are in the form of 'segment:offset'.
  ; In real mode, addresses are calculated as segment * 16 + offset.
  ; This means that 0000:7C00 and 07C0:0000 are technically the same address.

  [ORG 0x7c00]  ; set the origin to the correct physical address, 0x0000:0x7C00
  [BITS 16]

  ; 'cs' is the code segment where instructions live
  ; 'ds' is the data segment,
  ; 'ss' is the stack segment

  xor ax, ax
  mov ds, ax  ; set the data segment value to zero
  mov ss, ax  ; stack starts at 0

  cld         ; clear direction flag (forward direction for string instructions)

  mov si, msg
  call bios_print

bios_print:
  lodsb               ; mov al, [si] ;  inc si
  or al, al           ; check if we reached the null-byte of the string
  jz bios_print_done  ; exit if so
  mov ah, 0x0E        ; high byte of ax to BIOS function 0x0E = Teletype output
  mov bh, 0           ; high byte of bx
  int 0x10            ; call interrupt to bios video services
  jmp bios_print
bios_print_done:
  ret


hang:
  jmp hang

  ; print with carriage return, newline, and null-byte
  msg db "Bootloader started", 13, 10, 0

  ; $$ is the start address of the current segment
  ; $ is the current address
  ; $-$$ is the amount of bytes emitted so far in this segment
  ; we are filling up the remaining bytes with 0 to fulfill a 512 byte segment for BIOS
  times 510-($-$$) db 0

  ; in legacy bootloaders and qemu, this 0xAA55 boot signature is needed
  db 0x55
  db 0xAA
