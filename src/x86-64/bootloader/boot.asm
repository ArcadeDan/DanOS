BITS 64

section     .data


section     .text
global      _start

_start:



signature:

    times 0200h - 2 - ($ - $$)  db 0
    dw 0AA55h


section     .bss