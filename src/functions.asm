quit:
    mov rax, 60
    mov rdi, 0
    syscall
    ret

; Quits with the error code in rdi 
quit_err:
    mov rax, 60
    syscall
    ret

; ======= Print to STDOUT ======= 
; int write(int fd, const void *buf, size_t count)
;    Source: https://pubs.opengroup.org/onlinepubs/009695399/functions/write.html
;
; The opcode for sys_write() is 1
; fd: File Descriptor (1 = STDOUT)
; rsi: Message (provided by caller)
; rdx: Message Length (provided by caller)
print:
    mov  rax, 1                ; sys_write()
    mov  rdi, 1                ; STDOUT
    syscall
    ret

; ======= Print to STDOUT with Line Feed =======
; Identical to print, but appends a line feed
printLF:
    call print
    mov  rsi, 0ah             ; Line Feed
    mov  rdx, 1               ; Length of Line Feed
    push rsi

    mov  rsi, rsp
    call print
    pop  rsi
    ret

; ======= Print Unknown Length =======
; Prints a message with an unknown length
;
; rdi: Message (provided by caller)
print_unk:
    push rbp
    mov  rbp, rsp
    push rbx

    lea  rbx, [rdi]
    mov  rdx, 0
    
    .count:
        cmp  byte [rbx], 0

    .sigma:
        je   .print
        inc  rdx
        inc  rbx
        jmp  .count

    .print:
        cmp  rdx, 0
        je   .done

        mov  rax, 1
        mov  rsi, rdi
        mov  rdi, 1
        syscall

    .done:
        pop  rbx
        pop  rbp
        ret
