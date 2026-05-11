  [BITS 32]

  %define PAGE_PRESENT (1 << 0)
  %define PAGE_WRITE (1 << 1)
  %define PAGING_DATA 0x20000

  ; edi -> points to a valid page-aligned 16KiB buffer, for the PML4, PDPT, PD and a PT.
  ; ss:esp -> points to memory that can be used as a small stack
enable_paging:
  mov edi, PAGING_DATA  ; Point edi to a free space to create the paging structures

  ; zero out the 16KiB buffer. since we are doing a rep stosd, count should be bytes/4.
  push edi ; REP STOSD alters EDI.
  mov ecx, 0x1000
  xor eax, eax
  cld
  rep stosd
  pop edi ; Get EDI back.

  ; Build the Page Map Level 4. edi points to the Page Map Level 4 table.
  lea eax, [edi + 0x1000]           ; Put the address of the Page Directory Pointer Table in to EAX.
  or eax, PAGE_PRESENT | PAGE_WRITE ; Or EAX with the flags - present flag, writable flag.
  mov [edi], eax                    ; Store the value of EAX as the first PML4E.

  ; Build the Page Directory Pointer Table.
  lea eax, [edi + 0x2000]           ; Put the address of the Page Directory in to EAX.
  or eax, PAGE_PRESENT | PAGE_WRITE ; Or EAX with the flags - present flag, writable flag.
  mov [edi + 0x1000], eax           ; Store the value of EAX as the first PDPTE.

  ; Build the Page Directory.
  lea eax, [edi + 0x3000]           ; Put the address of the Page Table in to EAX.
  or eax, PAGE_PRESENT | PAGE_WRITE ; Or EAX with the flags - present flag, writeable flag.
  mov [edi + 0x2000], eax           ; Store to value of EAX as the first PDE.

  push edi                              ; Save EDI for the time being.
  lea edi, [edi + 0x3000]               ; Point EDI to the page table.
  mov eax, PAGE_PRESENT | PAGE_WRITE    ; Move the flags into EAX - and point it to 0x0000.

  ; Build the Page Table.
  .LoopPageTable:
  mov [edi], eax
  add eax, 0x1000
  add edi, 8
  cmp eax, 0x200000                 ; If we did all 2MiB, end.
  jb .LoopPageTable

  pop edi                           ; Restore EDI.
  ret
