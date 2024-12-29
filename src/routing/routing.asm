section .data
    ; ============= File Exts (Backwards) =============
    HTML_EXT     db      "lmth", 0h
    HTML_EXT_LEN equ     $ - HTML_EXT

    CSS_EXT      db      "ssc",  0h
    CSS_EXT_LEN  equ     $ - CSS_EXT

    JS_EXT       db      "sj",   0h
    JS_EXT_LEN   equ     $ - JS_EXT

    PNG_EXT      db      "gnp",  0h
    PNG_EXT_LEN  equ     $ - PNG_EXT

    ; ============= Responses ============
    html_http_200:
        db      "HTTP/1.1 200 OK",                      0dh, 0ah
        db      "Server: Tathya's Awesome Server",      0dh, 0ah
        db      "Content-Type: text/html",              0dh, 0ah
        db                                              0dh, 0ah
    html_http_200_len equ $ - html_http_200

    css_http_200:
        db      "HTTP/1.1 200 OK",                      0dh, 0ah
        db      "Server: Tathya's Awesome Server",      0dh, 0ah
        db      "Content-Type: text/css",               0dh, 0ah
        db                                              0dh, 0ah
    css_http_200_len equ $ - css_http_200

    js_http_200:
        db      "HTTP/1.1 200 OK",                      0dh, 0ah
        db      "Server: Tathya's Awesome Server",      0dh, 0ah
        db      "Content-Type: application/javascript", 0dh, 0ah
        db                                              0dh, 0ah
    js_http_200_len equ $ - js_http_200

    png_http_200:
        db      "HTTP/1.1 200 OK",                      0dh, 0ah
        db      "Server: Tathya's Awesome Server",      0dh, 0ah
        db      "Content-Type: image/png",              0dh, 0ah
        db                                              0dh, 0ah
    png_http_200_len equ $ - png_http_200

    fl_not_found db "templates/not_found.html",         0h

    ep_     db "/", 0h
    fl_ep_     db "templates/home/index.html", 0h

    ep_index_html     db "/index.html", 0h
    fl_ep_index_html     db "templates/home/index.html", 0h

    ep_style_css     db "/style.css", 0h
    fl_ep_style_css     db "templates/home/style.css", 0h

    ep_script_js     db "/script.js", 0h
    fl_ep_script_js     db "templates/home/script.js", 0h

    ep_image_png     db "/image.png", 0h
    fl_ep_image_png     db "templates/home/image.png", 0h

section .text
global process_file

%include 'src/routing/fs.asm'
%include 'src/functions.asm'

; ============= Process File =============
; Checks if the path matches any of the files
;
; If it does, it sends the file
; r10 holds the length of the path
; rsi holds the path
process_file:
    push rsi
    call f_process_file_ext
    pop  rsi

    .ep_:
        mov  rdi, ep_
        mov  rcx, r10
        call f_match_path
        cmp  rax, 1
        jne  .ep_index_html
        mov  rdi, fl_ep_
        ret

    .ep_index_html:
        mov  rdi, ep_index_html
        mov  rcx, r10
        call f_match_path
        cmp  rax, 1
        jne  .ep_style_css
        mov  rdi, fl_ep_index_html
        ret

    .ep_style_css:
        mov  rdi, ep_style_css
        mov  rcx, r10
        call f_match_path
        cmp  rax, 1
        jne  .ep_script_js
        mov  rdi, fl_ep_style_css
        ret

    .ep_script_js:
        mov  rdi, ep_script_js
        mov  rcx, r10
        call f_match_path
        cmp  rax, 1
        jne  .ep_image_png
        mov  rdi, fl_ep_script_js
        ret

    .ep_image_png:
        mov  rdi, ep_image_png
        mov  rcx, r10
        call f_match_path
        cmp  rax, 1
        jne  .not_found
        mov  rdi, fl_ep_image_png
        ret

    .not_found:
        mov  rdi, fl_not_found
        ret

