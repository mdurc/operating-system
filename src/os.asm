stage1_start:
  %include "stage1/stage1.asm"
stage1_end:

stage2_start:
  %include "stage2/stage2.asm"
  ; since we are loading stage 2 from disk, it should be an integer number of sectors (512 bytes)
  align 512, db 0
stage2_end:

kernel_start:
  %include "kernel/kernel.asm"
  align 512, db 0
kernel_end:
