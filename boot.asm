[org 0x7c00]
KERNEL_OFFSET equ 0x1000

jmp _start

;; DISK LOAD BEGIN
disk_load:
    pusha ; push all gpr to stack
    push dx

    mov ah, 0x02
    mov al, dh
    mov cl, 0x02

    mov ch, 0x00
    mov dh, 0x00

    int 0x13
    
    jc disk_error

    pop dx
    cmp al, dh

    jne sectors_error
    popa
    ret

disk_error:
    mov bx, DISK_ERROR
    call print
    call print_nl
    mov dh, ah 
    call print_hex 
    jmp disk_loop

sectors_error:
    mov bx, SECTORS_ERROR
    call print

disk_loop:
    jmp $

DISK_ERROR: db "Disk read error", 0
SECTORS_ERROR: db "Incorrect number of sectors read", 0
;; DISK LOAD END

;; PRINT SECTION START
print:
    pusha
start:
    mov al, [bx] 
    cmp al, 0 
    je done

    
    mov ah, 0x0e
    int 0x10 


    add bx, 1
    jmp start

done:
    popa
    ret



print_nl:
    pusha
    
    mov ah, 0x0e
    mov al, 0x0a 
    int 0x10
    mov al, 0x0d 
    int 0x10
    
    popa
    ret
;; PRINT SECTION END

;; PRINT HEX START
print_hex:
    pusha
    mov cx, 0 

hex_loop:
    cmp cx, 4 
    je end
    
    mov ax, dx 
    and ax, 0x000f 
    add al, 0x30 
    cmp al, 0x39 
    jle step2
    add al, 7 

step2:
    
    mov bx, HEX_OUT + 5 
    sub bx, cx  
    mov [bx], al 
    ror dx, 4 
    
    add cx, 1
    jmp hex_loop

end:
    
    mov bx, HEX_OUT
    call print

    popa
    ret

HEX_OUT:
    db '0x0000', 0 
;; PRINT HEX END

;; PRINT32 START
[bits 32]

VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f


print_string_pm:
    pusha
    mov edx, VIDEO_MEMORY

print_string_pm_loop:
    mov al, [ebx]
    mov ah, WHITE_ON_BLACK

    cmp al, 0
    je print_string_pm_done

    mov [edx], ax
    add ebx, 1
    add edx, 2

    jmp print_string_pm_loop

print_string_pm_done:
    popa
    ret
;; PRINT32 END

;; GDT START
gdt_start:
    dd 0x0
    dd 0x0

gdt_code:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0

gdt_data:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
;; GDT END

;; SWITCH32
[bits 16]

switch_to_pm:
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:init_pm


[bits 32]
init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000
    mov esp, ebp

    call BEGIN_PM
;; SWITCH32 END

;;start
_start:
    mov [BOOT_DRIVE], dl
    mov bp, 0x9000
    mov sp, bp

    mov bx, MSG_REAL_MODE
    call print
    call print_nl

    call load_kernel
    call switch_to_pm
    jmp $

[bits 16]
load_kernel:
    mov bx, MSG_LOAD_KERNEL
    call print
    call print_nl

    mov bx, KERNEL_OFFSET
    mov dh, 2
    mov dl, [BOOT_DRIVE]
    call disk_load
    ret



[bits 32]
BEGIN_PM:
    mov ebx, MSG_PROT_MODE
    call print_string_pm
    call KERNEL_OFFSET
    jmp $


BOOT_DRIVE db 0
MSG_REAL_MODE db "Started in 16-bit real mode", 0
MSG_PROT_MODE db "Loaded 32-bit protected mode", 0
MSG_LOAD_KERNEL db "Loading Kernel into memory", 0



times 0200h - 2 - ($ - $$)  db 0
dw 0AA55h