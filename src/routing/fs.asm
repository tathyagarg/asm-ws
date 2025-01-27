; ========== Match Path ==========
; Compares the path in rsi to the given path
;
; Returns 1 if the paths match, 0 otherwise
; Path to match is passed in in rdi
; Path to match against is in rsi
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

    ; Go 2 characters backwards to get to the actual last character in rsi
    dec  rsi
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

; ========== Process File Extension ==========
; Determines the HTTP Headers of the file based on the file extension
;
; Returns the HTTP Headers in r9 and the length in r8
; File name is passed in in r10
f_process_file_ext:
    mov  rdi, HTML_EXT
    mov  rcx, r10
    mov  r9, HTML_EXT_LEN 
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

    mov  rdi, JSON_EXT 
    mov  rcx, r10
    mov  r9,  JSON_EXT_LEN
    call f_match_file_ext
    cmp  rax, 1
    je   .json

    mov  rdi, OS_EXT 
    mov  rcx, r10
    mov  r9,  OS_EXT_LEN
    call f_match_file_ext
    cmp  rax, 1
    je   .os

    mov  rdi, SVG_EXT 
    mov  rcx, r10
    mov  r9,  SVG_EXT_LEN
    call f_match_file_ext
    cmp  rax, 1
    je   .svg

    mov  rdi, TTF_EXT 
    mov  rcx, r10
    mov  r9,  TTF_EXT_LEN
    call f_match_file_ext
    cmp  rax, 1
    je   .ttf

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

    .json:
        mov  r9, JSON_MIME
        mov  r8, JSON_MIME_LEN
        jmp .found

    .os:
        mov  r9, OS_MIME
        mov  r8, OS_MIME_LEN
        jmp .found

    .svg:
        mov  r9, SVG_MIME
        mov  r8, SVG_MIME_LEN
        jmp .found

    .ttf:
        mov  r9, TTF_MIME
        mov  r8, TTF_MIME_LEN
        jmp .found

    ; Add HTTP 200 Headers
    .found:
        call make_headers
        ret

    .not_found:
        mov  r9, HTTP_404
        mov  r8, HTTP_404_LEN
        ret

; ========== Make Headers ==========
; Concatenates the HTTP Headers to the mime type in r9, putting length in r8
make_headers:
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

    ; Add CRLF, CRLF 
    mov  byte [rax + HTTP_200_LEN + Content_Type_LEN + r8 + 0], 0dh
    mov  byte [rax + HTTP_200_LEN + Content_Type_LEN + r8 + 1], 0ah
    mov  byte [rax + HTTP_200_LEN + Content_Type_LEN + r8 + 2], 0dh
    mov  byte [rax + HTTP_200_LEN + Content_Type_LEN + r8 + 3], 0ah

    mov  r9, rax
    add  r8, HTTP_200_LEN
    add  r8, Content_Type_LEN
    add  r8, 4
    ret
