  [BITS 16]

  %define CodeSeg32 0x08
  %define DataSeg32 0x10
  %define CodeSeg64 0x18
  %define DataSeg64 0x20

  ; Global Descriptor Table
  ; Defines the characteristics of the various memory segments
  ; used during program execution, including the base address, size,
  ; and access privileges

gdt_start:
  ; Null Descriptor (0x00)
  dq 0x0000000000000000

  ; 32-bit Code Segment Descriptor (0x08)
  ; Base=0, Limit=0xFFFFF, D=1 (32-bit), P=1, S=1, Exec=1, RW=1, Ring 0
  ; Access Byte: 10011010b = 0x9A
  ; Flags: G=1, D=1 (32-bit), L=0 (64-bit off), AVL=0, LimitHi=0xF
  dq 0x00CF9A000000FFFF

  ; 32-bit Data Segment Descriptor (0x10)
  ; Same as code but Exec=0, RW=1
  dq 0x00CF92000000FFFF

  ; 64-bit Code Segment Descriptor (0x18)
  ; Base=0, Limit=0xFFFFF, G=1, L=1, D=0, P=1, S=1, Type=0xA (Exec=1, RW=1), DPL=0 (Ring 0)
  dq 0x00AF9A000000FFFF

  ; 64-bit Data Segment Descriptor (0x20)
  ; Base=0, Limit=0, L=1 (ignored for data), D=0, G=1, P=1, RW=1
  dq 0x00AF92000000FFFF
gdt_end:
gdt_descriptor:
  dw gdt_end - gdt_start - 1  ; Limit (size - 1)
  dd gdt_start                ; Base address of GDT
