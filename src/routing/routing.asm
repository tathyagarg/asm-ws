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

    ; ============= Files =============
    index_html:
        db      "templates/home/index.html", 0h
    index_html_len equ $ - index_html

    style_css:
        db      "templates/home/style.css",  0h
    style_css_len equ $ - style_css

    script_js:
        db      "templates/home/script.js",  0h
    script_js_len equ $ - script_js

    image_png:
        db      "templates/home/image.png",  0h
    image_png_len equ $ - image_png

    ; ============= Paths =============
    home           db      "/",                         0h
    home_len       equ     $ - home

    home_css       db      "/style.css",                0h
    home_css_len   equ     $ - home_css

    home_js        db      "/script.js",                0h
    home_js_len    equ     $ - home_js

    home_image     db      "/image.png",                0h
    home_image_len equ     $ - home_image

    html_http_200:
        db      "HTTP/1.1 200 OK",                      0dh, 0ah
        db      "Server: Tathya's Awesome Server",      0dh, 0ah
        db      "Content-Type: text/html",              0dh, 0ah
        db      0dh, 0ah
    html_http_200_len equ $ - html_http_200

    css_http_200:
        db      "HTTP/1.1 200 OK",                      0dh, 0ah
        db      "Server: Tathya's Awesome Server",      0dh, 0ah
        db      "Content-Type: text/css",               0dh, 0ah
        db      0dh, 0ah
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
    call _process_file_ext
    pop  rsi

    mov  rdi, home
    mov  rcx, r10
    call f_match_path
    cmp  rax, 1
    je   .send_home

    mov  rdi, home_css
    mov  rcx, r10
    call f_match_path
    cmp  rax, 1
    je   .send_home_css

    mov  rdi, home_js
    mov  rcx, r10
    call f_match_path
    cmp  rax, 1
    je   .send_home_js

    mov  rdi, home_image
    mov  rcx, r10
    call f_match_path
    cmp  rax, 1
    je   .send_home_image

    .send_home:
        mov  rdi, index_html
        ret
    
    .send_home_css:
        mov  rdi, style_css
        ret

    .send_home_js:
        mov  rdi, script_js
        ret

    .send_home_image:
        mov  rdi, image_png
        ret

_process_file_ext:
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
