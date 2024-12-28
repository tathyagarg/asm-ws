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
