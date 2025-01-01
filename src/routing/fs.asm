; ========== Match Path ==========
; Compares the path in [path] to the given path
;
; Returns 1 if the paths match, 0 otherwise
; Path to match is passed in in rdi
; Path to match against is in [path]
f_match_path:
    push rsi
    .match_path:
        mov  al, [rsi]
        cmp  al, [rdi]
        jne  .no_match
        inc  rsi
        inc  rdi
        dec  rcx
        jnz  .match_path

    .match:
        mov  rax, 1
        jmp  .done

    .no_match:
        mov  rax, 0
        jmp  .done
    
    .done:
        pop  rsi
        ret

; ========== Match File Extension ==========
; Compares the file name in rsi to the given extension in rdi
;
; Returns 1 if the extensions match, 0 otherwise
f_match_file_ext:
    push rsi
    add  rsi, rcx
    dec  rsi

    .match_ext:
        mov  al, [rsi]
        cmp  al, [rdi]
        jne  .no_match
        dec  rsi
        inc  rdi
        dec  r9
        cmp  r9, 1
        jne  .match_ext

    .match:
        mov  rax, 1
        jmp  .done

    .no_match:
        mov  rax, 0
        jmp  .done
    
    .done:
        pop  rsi
        ret

f_process_file_ext:
    mov  rdi, HTML_EXT
    mov  rcx, r10
    mov  r9,  HTML_EXT_LEN
    call f_match_file_ext
    cmp  rax, 1
    je   .html

    mov  rdi, CSS_EXT 
    mov  rcx, r10
    mov  r9,  CSS_EXT_LEN 
    call f_match_file_ext
    cmp  rax, 1
    je   .css

    mov  rdi, JS_EXT 
    mov  rcx, r10
    mov  r9,  JS_EXT_LEN
    call f_match_file_ext
    cmp  rax, 1
    je   .js

    mov  rdi, PNG_EXT 
    mov  rcx, r10
    mov  r9,  PNG_EXT_LEN
    call f_match_file_ext
    cmp  rax, 1
    je   .png

    mov  rdi, ICO_EXT 
    mov  rcx, r10
    mov  r9,  ICO_EXT_LEN
    call f_match_file_ext
    cmp  rax, 1
    je   .ico

    mov  rdi, NO_EXT
    mov  rcx, r10
    mov  r9,  NO_EXT_LEN
    call f_match_file_ext
    cmp  rax, 1
    jne   .not_found

    .html:
        mov  r9, HTML_MIME
        mov  r8, HTML_MIME_LEN
        jmp .found

    .css:
        mov  r9, CSS_MIME
        mov  r8, CSS_MIME_LEN
        jmp .found

    .js:
        mov  r9, JS_MIME
        mov  r8, JS_MIME_LEN
        jmp .found

    .png:
        mov  r9, PNG_MIME
        mov  r8, PNG_MIME_LEN
        jmp .found

    .ico:
        mov  r9, ICO_MIME
        mov  r8, ICO_MIME_LEN
        jmp .found

    ; Add HTTP 200 Headers
    .found:
        lea  rax, [response_headers]

        lea  rsi, [HTTP_200]
        lea  rdi, [rax]
        mov  rcx, HTTP_200_LEN 
        rep  movsb

        lea  rsi, [Content_Type]
        lea  rdi, [rax + HTTP_200_LEN]
        mov  rcx, Content_Type_LEN
        rep  movsb

        lea  rsi, [r9]
        lea  rdi, [rax + HTTP_200_LEN + Content_Type_LEN]
        mov  rcx, r8
        rep  movsb

        ; Add CRLF, CRLF, NULL
        mov  byte [rax + HTTP_200_LEN + Content_Type_LEN + r8 + 0], 0dh
        mov  byte [rax + HTTP_200_LEN + Content_Type_LEN + r8 + 1], 0ah
        mov  byte [rax + HTTP_200_LEN + Content_Type_LEN + r8 + 2], 0dh
        mov  byte [rax + HTTP_200_LEN + Content_Type_LEN + r8 + 3], 0ah
        mov  byte [rax + HTTP_200_LEN + Content_Type_LEN + r8 + 4], 0h

        mov  r9, rax
        add  r8, HTTP_200_LEN
        add  r8, Content_Type_LEN
        add  r8, 4

        ret

    .not_found:
        mov  r9, HTTP_404
        mov  r8, HTTP_404_LEN
        ret


