section .data
    socket      dq      0
    socket_on   dq      1
    max_backlog dw      10

    buf_len     equ     512              ; Request buffer length, 512 bytes
    req_buf     TIMES   buf_len db 0     ; Request buffer
    res_buf     TIMES   buf_len db 0     ; Response buffer
    req_len     dq      0                ; Request length


    client      dq      0

    address     dq      0100007Fh        ; 127.0.0.1 in big endian hex

    path_len    dq      0

    startup_msg:
        db      "Server started and listening on http://127.0.0.1:", 0h
    startup_msg_len equ $ - startup_msg

    ; ============= Debug =============
    %define DEBUG_HEADERS    1
    %define DEBUG_METHOD     1
    %define DEBUG_PATH       1
    %define DEBUG_RESP       1

    ; ============= Files =============
    file_ptr    dq      0

    ; ============= Methods =============
    GET        db       "GET",    0h
    GET_LEN    equ      $ - GET

    POST       db       "POST",   0h
    POST_LEN   equ      $ - POST

    PUT        db       "PUT",    0h
    PUT_LEN    equ      $ - PUT

    DELETE     db       "DELETE", 0h
    DELETE_LEN equ      $ - DELETE

    idx_GET    equ      0
    idx_POST   equ      1
    idx_PUT    equ      2
    idx_DELETE equ      3

    ; ============= Response Types =============
    RT_FILE    equ      0
    RT_EXEC    equ      1

    ; ============= System Calls =============
    %define SYS_READ        0
    %define SYS_WRITE       1
    %define SYS_OPEN        2
    %define SYS_DUP         32
    %define SYS_DUP2        33
    %define SYS_SOCKET      41
    %define SYS_ACCEPT      43
    %define SYS_SHUTDOWN    48
    %define SYS_BIND        49
    %define SYS_LISTEN      50
    %define SYS_SETSOCKOPT  54
    %define SYS_VFORK       58
    %define SYS_EXECVE      59
    %define SYS_EXIT        60
    %define SYS_WAIT4       61

    ; ============= Constants =============
    EXIT_SUCCESS   equ      0
    STDOUT         equ      1
    AF_INET        equ      2
    SOCK_STREAM    equ      1
    O_WRONLY       equ      0001o
    O_CREAT        equ      0100o
    O_TRUNC        equ      1000o

section .bss
    socket_addr resq    1  ; Declare 8 bytes of uninitialized memory
    method      resb    1 
    path        resb    256

    port        resw    1

section .text
extern process_file
extern make_headers

global _start

%include 'src/functions.asm'
%include 'src/sockets.asm'
%include 'src/parser.asm'

error_handler:
    cmp  rax, 0
    jne  _exit
    ret

jle_error_handler:
    cmp  rax, 0
    jle  _exit
    ret

; ============= Send File =============
; Sends a file to the client buffer
; Reads the file contents into res_buf and sends it to the client
; Loops until the file is completely read
;
; Parameters:
;   rbx: File pointer/descriptor (provided by caller)
send_file:
    ; Read the file contents
    mov  rdi, rbx
    mov  rsi, res_buf
    mov  rdx, buf_len
    call so_read_socket
    cmp  rax, 1                         ; Check if bytes read is < 1
    jl   .finish_send_file
    mov  rcx, rax                       ; Store bytes read to counter

    ; Write the file contents to the client
    mov  rdi, [client]
    mov  rsi, res_buf
    mov  rdx, rcx
    call so_write_socket
    jmp  send_file

    .finish_send_file:
        ret

; ============= Make Int =============
; Converts a string to an integer
;
; Parameters:
;   rsi: String to convert
;   rcx: Length of the string
make_int:
    mov rax, 0

    .divide_loop:
        ; Get 1 character from number
        mov  bl, byte [rsi]
        cmp  bl, 0
        je   .done

        sub  bl, 30h

        imul rax, rax, 10
        add  rax, rbx
        inc  rsi
        dec  rcx
        cmp  rcx, 0
        jg   .divide_loop

    .done:
        ret

_start:
    cmp word [rsp], 1
    je   _exit

    mov  r12, [rsp + 16]  ; Safekeeping the port number

    mov  rsi, [rsp + 16]
    mov  rcx, 5
    call make_int

    ; Endianness swap
    bswap eax
    shr   eax, 16
    mov  [port], rax

    call so_create_socket
    mov  [socket], rax                 ; Store socket file descriptor

    ; ========== Create Socket Address ==========
    ; The socket address structure is defined in netinet/in.h
    ; struct sockaddr_in {
    ;     sa_family_t    sin_family;  // Address Family
    ;     in_port_t      sin_port;    // Port Number
    ;     struct in_addr sin_addr;    // Internet Address
    ; };
    ;
    ; sin_family is the address family (AF_INET). Size: word (2 bytes)
    ; sin_port is the port number. Size: word (2 bytes)
    ; sin_addr is the internet address. Size: dword (4 bytes)
    ;
    ; When elements are pushed to the stack, rsp is decremented.
    ; This means to restore rsp to its original value, we need to add to it (not subtract!)
    ; 
    push rbp                             ; Store stack pointer (base)
    mov  rbp,  rsp                       ; Move stack top to base
    push qword [address]                 ; Push the address to the stack
    push word  [port]                    ; Push the port to the stack
    push word  2                         ; Push the address family (AF_INET) to the stack
    mov  [socket_addr], rsp              ; Store the address pointer
    add  rsp, 8                          ; Add to the stack pointer to restore its position 
    pop  rbp                             ; Restore original stack pointer

    mov  rdi, [socket]                   ; Load socket file descriptor
    mov  r10, socket_on                  ; Enable socket reuse
    call so_set_socket_options
    call error_handler

    ; Bind the socket to the address
    mov  rdi, [socket]
    mov  rsi, [socket_addr]
    call so_bind_socket
    call error_handler

    ; Print the startup message
    mov  rsi, startup_msg
    mov  rdx, startup_msg_len
    call print

    mov  rsi, r12
    mov  rdx, 5
    call printLF

    ; Listen for incoming connections
    mov  rdi, [socket]
    mov  rsi, [max_backlog]              ; Set the backlog to 10
    call so_listen

accept:
    ; Accept incoming connections
    mov  rdi, [socket]                   ; Load the socket file descriptor
    call so_accept_connection
    call jle_error_handler
    mov  [client], rax

    ; Read the request from the client
    mov  rdi, [client]
    mov  rsi, req_buf
    mov  rdx, buf_len 
    call so_read_socket
    mov  [req_len], rax

    ; Print the request headers, if DEBUG_HEADERS 
    %if DEBUG_HEADERS
        mov  rsi, req_buf
        mov  rdx, [req_len]
        call printLF
    %endif

parse_headers:
    mov  rsi, req_buf
    call p_parse_headers

    .method:
        %if DEBUG_METHOD
            cmp  byte [method], idx_GET
            je   .print_get 

            cmp  byte [method], idx_POST
            je   .print_post 

            cmp  byte [method], idx_PUT
            je   .print_put

            cmp  byte [method], idx_DELETE
            je   .print_delete

            .print_get:
                mov  rsi, GET
                mov  rdx, GET_LEN
                jmp  ._print 
            
            .print_post:
                mov  rsi, POST
                mov  rdx, POST_LEN
                jmp  ._print 

            .print_put:
                mov  rsi, PUT
                mov  rdx, PUT_LEN
                jmp  ._print 

            .print_delete:
                mov  rsi, DELETE
                mov  rdx, DELETE_LEN
                jmp  ._print

            ._print:
                call printLF
        %endif

    .path:
        %if DEBUG_PATH
            mov  rsi, path
            mov  rdx, [path_len]
            call printLF
        %endif

process_request:
    mov  rsi, path
    movzx r9, byte [method]
    call process_file
    push r9
    push r8

send_headers:
    cmp  r11, RT_FILE
    je   .file

    cmp  r11, RT_EXEC
    je   .exec

    .file:
        call so_open_file
        cmp  rax, 0
        jle  close_client                           ; Error
    
        ; Reset the counter
        mov  rcx, qword 0
        mov  [file_ptr], rax
    
        ; Write the HTTP 200 OK headers
        mov  rdi, [client]
        pop  rdx                                   ; Length of the headers
        pop  rsi                                   ; Headers
        call so_write_socket
    
        %if DEBUG_RESP
            call printLF
        %endif
    
        ; Send the file
        mov  rbx, [file_ptr]
        call send_file

        jmp  close_client

    .exec:
        push r10

        mov  rax, SYS_VFORK
        syscall

        test rax, rax
        jz   .child

        ; Wait for child process to complete with sys_wait4
        mov  rdi, 0
        mov  rsi, 0
        mov  rdx, 0
        mov  r10, 0
        mov  rax, SYS_WAIT4
        syscall

        pop  r8
        pop  r9
        call make_headers  ; r9 now holds the headers

        pop  rdi
        push r9
        push r8

        jmp  .file

        .child:
            mov  rax, SYS_EXECVE
            syscall

close_client:
    ; Close the client connection
    mov  rdi, [client]
    call so_close_socket
    jmp  accept

_exit:
    mov  rdi, [socket]
    call so_close_socket
    call quit

