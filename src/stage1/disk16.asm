  [BITS 16]

  ; BIOS Extended LBA disk read via IN 13h/AH=42h
  ; https://wiki.osdev.org/Disk_access_using_the_BIOS_(INT_13h)

DAP:
  db 0x10               ; size of packet = 16 bytes
  db 0                  ; always 0
  .num_sectors: dw 127  ; number of sectors to load (max = 127 on some BIOS)
  .buf_offset:  dw 0x0  ; 16-bit offset of target buffer
  .buf_segment: dw 0x0  ; 16-bit segment of target buffer
  .LBA_lower:   dd 0x0  ; lower 32 bits of 48-bit starting LBA
  .LBA_upper:   dd 0x0  ; upper 32 bits of 48-bit starting LBA

  boot_drive db 0
  boot_msg db "Booting Stage 2...", 0
  disk_err_msg db "Disk Error!", 0

  ; ======================================
  ; ax <- start of sector
  ; cx <- number of sectors (512 bytes) to load
  ; bx <- offset of buffer
  ; dx <- segment of buffer
  ; loads disk sectors into memory (int 13h, function code 42h)
load_disk:
  .chunk:
  cmp cx, 127     ; this is the max sectors to read in one call
  jbe .load

  pusha           ; save current register states
  mov cx, 127
  call load_disk  ; read the 127 sectors and then restore state
  popa

  add dx, 127 * 512 / 16  ; point to the next memory buffer after the 127 sectors
  sub cx, 127             ; decrease sectors left to read
  jmp .load


  .load:
  mov [DAP.LBA_lower], ax
  mov [DAP.num_sectors], cx
  mov [DAP.buf_segment], dx
  mov [DAP.buf_offset], bx
  mov dl, [boot_drive]
  mov si, DAP
  mov ah, 0x42
  int 0x13
  jc .print_error
  ret

  .print_error:
  mov si, disk_err_msg
  call sprint16

  .halt: hlt
  jmp .halt
