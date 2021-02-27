windows: main.cpp
	x86_64-w64-mingw32-g++ -static-libgcc -static-libstdc++ main.cpp

linux: main.cpp
	g++ -o program main.cpp

debug: main.cpp
	g++ -g -o debug main.cpp


asm: test.asm
	nasm -f elf64 -o test test.asm
	ld -o testasm test
	rm test