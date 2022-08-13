CC     =  gcc -march=i386  -m32 -fno-pie -nostdlib -ffreestanding
ASMBLR =  nasm


compile:
	$(CC) -c *.c
	$(CC) boot.o kernel.o

assemble:
	$(ASMBLR) -f bin -o boot.o boot.asm

clean:
	rm *.o

build:
	$(CC)     -c kernel.c
	$(ASMBLR) -o boot.o boot.asm
	$(ASMBLR) -o kernel_enter.o -f elf kernel_enter.asm
	ld -m elf_i386 -s -o danos.img kernel.o kernel_enter.o --oformat binary
	cat boot.o danos.img > DanOS-image.bin
	