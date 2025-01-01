section .data
    filename db '/bin/ls', 0        ; Program to execute
    len equ $ - filename

    argv     dq filename, 0        ; Arguments (null-terminated array of pointers)
    envp     dq 0                  ; Null pointer for environment variables

section .text
    global _start

_start:
    ; Step 1: Fork the process
    mov rax, 57                    ; syscall: fork
    syscall

    test rax, rax                  ; Check if in parent or child
    jz child_process               ; rax == 0 -> child process
    jg parent_process              ; rax > 0 -> parent process

    ; Error case
    mov rdi, 1                     ; Exit code 1 (error)
    jmp exit_program

child_process:
    ; Step 2: Call execve in child
    lea rdi, [filename]            ; Path to program
    lea rsi, [argv]                ; Pointer to arguments array
    lea rdx, [envp]                ; Pointer to environment variables
    mov rax, 59                    ; syscall: execve
    syscall

    ; If execve fails, exit child process with error
    mov rdi, 1                     ; Exit code 1
    jmp exit_program

parent_process:
    ; Step 3: Wait for child process to finish
    mov rdi, -1                    ; Wait for any child process
    xor rsi, rsi                   ; Options = 0
    mov rax, 61                    ; syscall: waitpid
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, filename
    mov rdx, len
    syscall

    ; Step 4: Continue execution
    ; Your program can now do more work here

exit_program:
    mov rax, 60                    ; syscall: exit
    xor rdi, rdi                   ; Exit code 0
    syscall
