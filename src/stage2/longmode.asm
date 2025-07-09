  [BITS 32]

  ; https://wiki.osdev.org/Entering_Long_Mode_Directly
  ; Checks whether CPU supports long mode or not.
  ; returns eax = 0 if long mode is not supported
is_longmode_supported:
  mov eax, 0x80000000 ; load the highest extended CPUID function number
  cpuid               ; get CPU info on supported extended functions
  cmp eax, 0x80000001 ; check if function 0x80000001 is supported
  jb .not_supported

  mov eax, 0x80000001 ; after calling CPUID with EAX = 0x80000001,
  cpuid               ; all AMD64 compliant processors have the longmode-capable-bit
  test edx, (1 << 29)

  jz .not_supported   ; if it's not set, there is no long mode.
  ret

  .not_supported:
  xor eax, eax
  ret

enter_longmode:
  mov edi, PAGING_DATA  ; Point edi at the PAGING_DATA.
  mov eax, 0b10100000   ; Set the PAE and PGE bit.
  mov cr4, eax
  mov edx, edi          ; Point CR3 at the PML4.
  mov cr3, edx
  mov ecx, 0xC0000080   ; Read from the EFER MSR.
  rdmsr
  or eax, 0x00000100    ; Set the LME bit.
  wrmsr
  mov ebx, cr0          ; Activate long mode
  or ebx,0x80000001     ; enable paging and protection simultaneously.
  mov cr0, ebx
  ; we loaded the gdt_descriptor to enter protected mode, so we don't have to now
  ; load CS with 64 bit segment and flush pipeline to enter long mode
  jmp CodeSeg64:kernel_entry
