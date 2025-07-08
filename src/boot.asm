  ; The CPU starts in 16 bit real mode and the BIOS loads this code at address 0000:7c00.
  ; These addresses are in the form of 'segment:offset'.
  ; In real mode, addresses are calculated as segment * 16 + offset.
  ; This means that 0000:7C00 and 07C0:0000 are technically the same address.

  [ORG 0x7c00]  ; set the origin to the correct physical address, 0x0000:0x7C00
  [BITS 16]

  jmp start

  %include "print16.inc"
  %include "keyhandler16.inc"

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

  ; printing and enabling keyhandler driver for 16 bit real mode
  mov si, start_msg16
  call sprint16
  mov si, start_msg16
  call bios_print
  ;call setup_keyhandler

  %include "protected_mode.inc"

  jmp $

  ; ===========

  ; $$ is the start address of the current segment
  ; $ is the current address
  ; $-$$ is the amount of bytes emitted so far in this segment
  ; we are filling up the remaining bytes with 0 to fulfill a 512 byte segment for BIOS
  times 510-($-$$) db 0

  ; in legacy bootloaders and qemu, this 0xAA55 boot signature is needed
  db 0x55
  db 0xAA
