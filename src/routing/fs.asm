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

    .html:
        mov  r9, html_http_200
        mov  r8, html_http_200_len
        ret

    .css:
        mov  r9, css_http_200
        mov  r8, css_http_200_len
        ret

    .js:
        mov  r9, js_http_200
        mov  r8, js_http_200_len
        ret

    .png:
        mov  r9, png_http_200
        mov  r8, png_http_200_len
        ret

    .ico:
        mov  r9, ico_http_200
        mov  r8, ico_http_200_len
        ret
