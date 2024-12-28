%include 'src/functions.asm'
%include 'src/sockets.asm'

section .data
    socket      dq      0
    address     dq      0100007Fh        ; 127.0.0.1 in big endian hex
    port        dw      901Fh            ; 8080 in little endian hex

section .bss
    socket_addr resq    1  ; Declare 8 bytes of uninitialized memory

section .text
global _start

_start:
    call create_socket
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

    mov  rdi, [socket]
    call set_socket_options

    call close_socket
    call quit

