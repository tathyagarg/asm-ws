section .data
    message db 'Hello, World!', 0xa
    message_len equ $ - message

section .text
global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, message
    mov edx, message_len
    int 0x80

    mov eax, 1
    mov ebx, 0
    int 0x80
