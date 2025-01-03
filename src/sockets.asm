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
so_create_socket:
    mov     rax, SYS_SOCKET          ; sys_socket()
    mov     rdi, AF_INET             ; AF_INET
    mov     rsi, SOCK_STREAM         ; SOCK_STREAM
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
; socket: socket file descriptor (provided by caller in rdi)
; how: 2 (SHUT_RDWR) - Disables further send and receive operations
; 
; Returns: 0 on success, -1 on error
so_close_socket:
    mov     rax, SYS_SHUTDOWN        ; sys_shutdown()
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
; option_value: 1 (Enable), (provided by caller in r10)
; option_len: sizeof(int) = 4 bytes
;
; Returns: 0 on success, -1 on error
so_set_socket_options:
    mov     rax, SYS_SETSOCKOPT      ; sys_setsockopt()
    mov     rsi, 1                   ; SOL_SOCKET
    mov     rdx, 2                   ; SO_REUSEADDR
    mov     r8,  dword 4             ; Load option_len
    syscall
    ret

; ======= Bind Socket =======
; int bind(int socket, const struct sockaddr *address, socklen_t address_len)
;    Source: https://pubs.opengroup.org/onlinepubs/009695399/functions/bind.html
;
; The opcode for sys_bind() is 49
; socket: socket file descriptor (provided by caller in rdi)
; address: pointer to sockaddr structure (provided by caller in rsi)
; address_len: sizeof(sockaddr) = 16 bytes (confusing, but it's the size of the structure)
; 
; Returns: 0 on success, -1 on error
so_bind_socket:
    mov     rax, SYS_BIND            ; sys_bind()
    mov     rdx, 16                  ; Load 16 byte socket address size
    syscall
    ret

; ======= Listen =======
; int listen(int socket, int backlog)
;    Source: https://pubs.opengroup.org/onlinepubs/009695399/functions/listen.html
;
; The opcode for sys_listen() is 50
; socket: socket file descriptor (provided by caller in rdi)
; backlog: Maximum number of pending connections (provided by caller in rsi)
;
; Returns: 0 on success, -1 on error
so_listen:
    mov     rax, SYS_LISTEN           ; sys_listen()
    syscall
    ret

; ======= Accept Connection =======
; int accept(int socket, struct sockaddr *restrict address, socklen_t *restrict address_len)
;    Source: https://pubs.opengroup.org/onlinepubs/009695399/functions/accept.html
;
; The opcode for sys_accept() is 43
; socket: socket file descriptor (provided by caller in rdi)
; address: NULL (we don't need the client address)
; address_len: NULL (we don't need the client address length)
;
; Returns: socket file descriptor on success, -1 on error
so_accept_connection:
    mov     rax, SYS_ACCEPT          ; sys_accept()
    mov     rsi, 0                   ; NULL
    mov     rdx, 0                   ; NULL
    syscall
    ret

; ======= Read from Socket =======
; ssize_t read(int fd, void *buf, size_t count)
;    Source: https://pubs.opengroup.org/onlinepubs/009695399/functions/read.html
;
; The opcode for sys_read() is 0
; fd: File Descriptor (provided by caller in rdi)
; buf: Buffer to read into (provided by caller in rsi)
; count: Number of bytes to read (provided by caller in rdx)
;
; Returns: Number of bytes read on success, -1 on error
so_read_socket:
    mov     rax, SYS_READ                   ; sys_read()
    syscall
    ret

; ======= Read HTML =======
; int open(const char *path, int oflag)
;    Source: https://pubs.opengroup.org/onlinepubs/009695399/functions/open.html
;
; The opcode for sys_open() is 2
; path: Path to the file (provided by caller in rdi)
; oflag: O_RDONLY = 0 (Read Only)
;
; Returns: File descriptor on success, -1 on error
so_open_file:
    mov     rax, SYS_OPEN                   ; sys_open()
    mov     rsi, 0                          ; O_RDONLY
    syscall
    ret

; ======= Write to Socket =======
; ssize_t write(int fd, const void *buf, size_t count)
;    Source: https://pubs.opengroup.org/onlinepubs/009695399/functions/write.html
;
; The opcode for sys_write() is 1
; fd: File Descriptor (provided by caller in rdi)
; buf: Buffer to write (provided by caller in rsi)
; count: Number of bytes to write (provided by caller in rdx)
;
; Returns: Number of bytes written on success, -1 on error
so_write_socket:
    mov     rax, SYS_WRITE                   ; sys_write()
    syscall
    ret
