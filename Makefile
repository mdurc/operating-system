MYCOMPILER = ../lang-dev/mylang/mylang-compiler/compiler_build_files/mycompiler

all: os

main.asm: src/kernel/main.sn .force-rebuild
	$(MYCOMPILER) --target=macos --arch=x86_64 --freestanding --asm src/kernel/main.sn main.asm

os: src/os.asm main.asm .force-rebuild
	nasm -I src -fbin src/os.asm -o os.bin

start: os
	qemu-system-x86_64 -drive format=raw,file=os.bin -d int,cpu_reset -no-reboot > LOG.txt 2>&1

clean:
	rm -f os.bin main.asm LOG.txt

.PHONY: start, clean, .force-rebuild
