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

; ======= Set Socket options =======
; int setsockopt(int socket, int level, int option_name, const void *option_value, socklen_t option_len)
;    Source: https://pubs.opengroup.org/onlinepubs/009695399/functions/setsockopt.html
;
; The opcode for sys_setsockopt() is 54
; socket: socket file descriptor (provided by caller in rdi)
; level: SOL_SOCKET = 1
; option_name: SO_REUSEADDR = 2
; option_value: 1 (Enable)
; option_len: sizeof(int) = 4 bytes = 32 bits
;
; Returns: 0 on success, -1 on error
set_socket_options:
    mov     rax, 54                  ; sys_setsockopt()
    mov     rsi, 1                   ; SOL_SOCKET
    mov     rdx, 2                   ; SO_REUSEADDR
    mov     r10, 1                   ; Load option_value
    mov     r8,  4                   ; Load option_len
    syscall
    ret
