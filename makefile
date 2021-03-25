
bootloader:

	cd src/x86-64/bootloader && nasm -f elf32 -o bootloader.o boot.asm
	mv src/x86-64/bootloader/bootloader.o ../DanOS


kernel:
	i686-elf-gcc -c -o kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra ./src/impl/kernel.c
	
link:
	i686-elf-gcc -T ./src/linker/linker.ld -o DanOS.bin -ffreestanding -O2 -nostdlib bootloader.o kernel.o -lgcc


binary:
	make bootloader
	make kernel
	make link