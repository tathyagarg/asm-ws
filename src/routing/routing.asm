section .data
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

process_file:
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
        mov  rsi, html_http_200
        mov  rdx, html_http_200_len
        ret
    
    .send_home_css:
        mov  rdi, style_css
        mov  rsi, css_http_200
        mov  rdx, css_http_200_len
        ret

    .send_home_js:
        mov  rdi, script_js
        mov  rsi, js_http_200
        mov  rdx, js_http_200_len
        ret

    .send_home_image:
        mov  rdi, image_png
        mov  rsi, png_http_200
        mov  rdx, png_http_200_len
        ret

