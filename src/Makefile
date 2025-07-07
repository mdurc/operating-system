all: boot

boot: boot.asm .force-rebuild
	nasm -fbin boot.asm -o boot.bin

start: boot
	qemu-system-x86_64 -drive format=raw,file=boot.bin

clean:
	rm *.bin

.PHONY: start, clean, .force-rebuild
