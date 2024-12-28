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
    mov rax, 1                ; sys_write()
    mov rdi, 1                ; STDOUT
    syscall
    ret
