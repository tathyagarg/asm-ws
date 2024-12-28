; ======= Create Socket =======
; The socket creation function, from sys/socket.h is:
; int socket(int domain, int type, int protocol)
;     Source: https://pubs.opengroup.org/onlinepubs/009619199/socket.htm
;
; The opcode for sys_socket() is 41
; domain: AF_INET = 2  (Address Format Internet Domain)
; type: SOCK_STREAM = 1 (Byte Stream, TCP)
; protocol: 0 (Default Protocol)
; 
; Returns: socket file descriptor
create_socket:
    mov     rax, 41                  ; sys_socket()
    mov     rdi, 2                   ; AF_INET
    mov     rsi, 1                   ; SOCK_STREAM
    mov     rdx, 0                   ; Protocol
    syscall
    ret

; ======= Close Socket =======
; We can use sys_close() to close the socket, which is opcode 3
; Instead, we will use sys_shutdown() to gracefully close the socket
; int shutdown(int socket, int how)
;     Source: https://pubs.opengroup.org/onlinepubs/009695399/functions/shutdown.html
;
; The opcode for sys_shutdown() is 48
; socket: socket file descriptor
; how: 2 (SHUT_RDWR) - Disables further send and receive operations
; 
; Returns: 0 on success, -1 on error
close_socket:
    push rax
    mov     rax, 48                  ; sys_shutdown()
    pop     rdi                      ; Load socket file descriptor
    mov     rsi, 2                   ; SHUT_RDWR
    syscall
    ret
