all: os

os: os.asm .force-rebuild
	nasm -fbin os.asm -o os.bin

start: os
	qemu-system-x86_64 -drive format=raw,file=os.bin

clean:
	rm *.bin

.PHONY: start, clean, .force-rebuild
