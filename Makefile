MYCOMPILER = ../lang-dev/mylang/mylang-compiler/compiler_build_files/mycompiler

all: os

kernel_entry.asm: src/kernel/kernel_entry.sn .force-rebuild
	$(MYCOMPILER) --target=macos --arch=x86_64 --freestanding --asm src/kernel/kernel_entry.sn kernel_entry.asm

os: src/os.asm kernel_entry.asm .force-rebuild
	nasm -I src/ -fbin src/os.asm -o os.bin

start: os
	qemu-system-x86_64 -drive format=raw,file=os.bin

clean:
	rm -f os.bin kernel_entry.asm

.PHONY: start, clean, .force-rebuild
