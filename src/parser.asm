

; ============== Parse HTTP Request Headers =============
; Parses the HTTP request headers and stores them in the following format:
;   - Method: GET, POST, PUT, DELETE, etc. in [method]
;   - Path: /home, /about, /contact, etc. in [path]
;
; Headers are passed in in rsi
p_parse_headers:
    call p_parse_method
    call p_parse_path
    ret


; ============== Parse HTTP Request Method =============
; Matches the HTTP headers against a given method
;
; Headers are passed in in rsi
; Returns the index of the matched method in [method]
; 
; Puts the matched method's length in rcx
p_parse_method:
    push rsi
    mov  rdi, GET
    mov  rcx, GET_LEN
    call _match_method
    pop  rsi
    cmp  rax, 1
    je   .get

    push rsi
    mov  rdi, POST
    mov  rcx, POST_LEN
    call _match_method
    pop  rsi
    cmp  rax, 1
    je   .post

    push rsi
    mov  rdi, PUT
    mov  rcx, PUT_LEN
    call _match_method
    pop  rsi
    cmp  rax, 1
    je   .put

    push rsi
    mov  rdi, DELETE
    mov  rcx, DELETE_LEN
    call _match_method
    pop  rsi
    cmp  rax, 1
    je   .delete

    ; If no match, return -1
    mov  rax, -1
    ret

    .get:
        mov  byte [method], idx_GET 
        ret

    .post:
        mov  byte [method], idx_POST
        ret

    .put:
        mov  byte [method], idx_PUT
        ret

    .delete:
        mov  byte [method], idx_DELETE
        ret

; ============== Parse HTTP Request Method =============
; Matches the HTTP headers against a given method
;
; Headers are passed in in rsi  
; Method to match is passed in in rdi 
; Length of the method is passed in in rcx
; Returns 1 if match, 0 if no match
_match_method:
    mov  al, byte [rsi]                 ; Move a character from the headers into al
    mov  bl, byte [rdi]                 ; Move a character from the method into bl
    cmp  al, bl
    jne  .no_match
    inc  rsi
    inc  rdi
    dec  rcx
    cmp  rcx, 1                         ; We compare to 1 and not 0 to ignore the null terminator
    jne  _match_method

    .match:
        mov  rax, 1
        ret

    .no_match:
        mov rax, 0
        ret
    
; ============== Get Request Path =============
; Parses the HTTP request headers and stores the path in [path]
;
; Headers are passed in in rsi
p_parse_path:
    mov  dword [path_len], 0
    mov  rdi, path
    .skip_method:
        mov  al, byte [rsi]
        cmp  al, ' '
        je   .found_space
        inc  rsi
        jmp  .skip_method

    .found_space:
        inc  rsi

    .copy_loop:
        mov  al, byte [rsi]
        cmp  al, ' '
        je   .done
        mov  byte [rdi], al
        inc  dword [path_len]
        inc  rsi
        inc  rdi
        jmp  .copy_loop

    .done:
        mov  byte [rdi], 0
        ret

