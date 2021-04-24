
bootloader:

	cd src/x86-64/bootloader && nasm -f bin -o bootloader.bin boot.asm
	mv src/x86-64/bootloader/bootloader.bin ../DanOS


kernel:
	i686-elf-gcc -c -o kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra ./src/impl/kernel.c
	
link:
	i686-elf-gcc -T ./src/linker/linker.ld -o DanOS.bin -ffreestanding -O2 -nostdlib bootloader.o kernel.o -lgcc


binary:
	make bootloader
	make kernel
	
	

entry:
	cd src/x86-64/bootloader && nasm -f elf -o kernel_enter.o kernel_enter.asm
	mv src/x86-64/bootloader/kernel_enter.o ../DanOS

final:
	make binary
	make entry
	i686-elf-ld -o DanOS.bin -Ttext 0x1000 kernel.o kernel_enter.o --oformat binary
	cat bootloader.bin DanOS.bin > DanOS-image.bin
	sudo qemu-img resize DanOS-image.bin +20K