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
load_disk:
  .chunk:
  cmp cx, 0       ; Check if there are sectors left to read
  je .done

  pusha           ; Save registers (preserves the remaining cx count)
  mov cx, 1       ; Read exactly 1 sector (512 bytes)
  call .load
  popa            ; Restore registers 

  add ax, 1       ; Advance LBA head by 1 sector
  add dx, 0x0020  ; Advance buffer segment by 512 bytes (0x20 paragraphs)
  dec cx          ; Decrement remaining sectors
  jmp .chunk

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

  .done:
  ret
