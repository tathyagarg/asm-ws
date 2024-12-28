; ======= Creates a socket =======
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
    mov     rax,41                  ; sys_socket()
    mov     rdi,2                   ; AF_INET
    mov     rsi,1                   ; SOCK_STREAM
    mov     rdx,0                   ; Protocol
    syscall
    ret
