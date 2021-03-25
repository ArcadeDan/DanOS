
bootloader:

	cd src/x86-64/bootloader && nasm -f elf32 -o bootloader.o boot.asm
	mv src/x86-64/bootloader/bootloader.o /mnt/c/Users/Daniel/Documents/git/DanOS/DanOS/

kernel_entry:
	nasm -f elf src/x86-64/bootloader/kernel_enter.asm -o kernel_enter.o

kernel.bin:
	i686-elf-ld -o kernel.bin -Ttext 0x1000 kernel.o kernel_enter.o --oformat binary

kernel:
	i686-elf-gcc -c -o kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra ./src/impl/kernel.c
	
link:
	i686-elf-gcc -T ./src/linker/linker.ld -o DanOS.bin -ffreestanding -O2 -nostdlib bootloader.o kernel.bin -lgcc


binary:
	make bootloader
	make kernel
	make kernel_entry
	make kernel.bin
	make link