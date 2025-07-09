  ; The CPU starts in 16 bit real mode and the BIOS loads this code at address 0000:7c00.
  ; These addresses are in the form of 'segment:offset'.
  ; In real mode, addresses are calculated as segment * 16 + offset.
  ; This means that 0000:7C00 and 07C0:0000 are technically the same address.

  [ORG 0x7c00]  ; set the origin to the correct physical address, 0x0000:0x7C00
  [BITS 16]

  jmp start

  %include "stage1/disk16.asm"
  %include "stage1/print16.asm"
  %include "stage1/keyhandler16.asm"

start:
  ; 'cs' is the code segment where instructions live
  ; 'ds' is the data segment,
  ; 'ss' is the stack segment
  ; 'sp' is the stack pointer that grows downward in the segment of 'ss'
  ; 'es' is the extra segment for text video memory

  ; perform a far jump to account for different BIOS loading points
  ; reloading 'cs', code segment where instructions live, to 0x0000
  jmp 0x0000:.setup_segments
  .setup_segments:
  xor ax, ax
  mov ds, ax      ; data segment
  mov ss, ax      ; stack segment
  mov sp, 0x9c00  ; stack pointer growing downward, 2000h past code start
  mov fs, ax      ; extra segment register
  mov gs, ax      ; extra segment register

  ; 0xb8000 physical address is the start of color text video memory
  mov ax, 0xb800  ; 16 * 0xb800 is the desired address for VRAM
  mov es, ax

  cld             ; clear direction flag to increment forward in pseudo-instructions

  ; load stage2 from disk to RAM
  mov [boot_drive], dl  ; we will have to restore this drive number of the booted device
  mov ax, (stage2_start - stage1_start) / 512   ; ax: start of stage 2 sector relative to stage 1
  mov cx, (kernel_end - stage2_start) / 512     ; cx: number of sectors (512 bytes) to load
  xor dx, dx                                    ; dx: segment of buffer
  mov bx, stage2_start                          ; bx: offset of buffer
  call load_disk

  ; real mode printing
  mov si, start_msg16
  call bios_print
  mov si, start_msg16
  call sprint16
  ;call setup_keyhandler

  jmp stage2_entry

  .halt: hlt
  jmp .halt

  ; ===========

  ; $$ is the start address of the current segment
  ; $ is the current address
  ; $-$$ is the amount of bytes emitted so far in this segment
  ; we are filling up the remaining bytes with 0 to fulfill a 512 byte segment for BIOS
  times 510-($-$$) db 0

  ; in legacy bootloaders and qemu, this 0xAA55 boot signature is needed
  db 0x55
  db 0xAA
