section .data
    NULL          equ 0

    ; ============================== File Extensions ==============================
    HTML_EXT      db "lmth", 0
    HTML_EXT_LEN  equ $ - HTML_EXT

    CSS_EXT       db "ssc", 0
    CSS_EXT_LEN   equ $ - CSS_EXT

    JS_EXT        db "sj", 0
    JS_EXT_LEN    equ $ - JS_EXT

    PNG_EXT       db "gnp", 0
    PNG_EXT_LEN   equ $ - PNG_EXT

    ICO_EXT       db "oci", 0
    ICO_EXT_LEN   equ $ - ICO_EXT

    NO_EXT        db "/", 0
    NO_EXT_LEN    equ $ - NO_EXT

    ; ============================== Responses ==============================
    HTTP_200:
        db "HTTP/1.1 200 OK",                          0dh, 0ah
        db "Server: Tathya's Awesome Assembly Server", 0dh, 0ah
    HTTP_200_LEN equ $ - HTTP_200

    HTTP_404:
        db "HTTP/1.1 404 Not Found",                   0dh, 0ah
        db "Server: Tathya's Awesome Assembly Server", 0dh, 0ah
    HTTP_404_LEN equ $ - HTTP_404

    Content_Type     db "Content-Type: "
    Content_Type_LEN equ $ - Content_Type

    HTML_MIME        db "text/html"
    HTML_MIME_LEN    equ $ - HTML_MIME

    CSS_MIME         db "text/css"
    CSS_MIME_LEN     equ $ - CSS_MIME

    JS_MIME          db "application/javascript"
    JS_MIME_LEN      equ $ - JS_MIME

    PNG_MIME         db "image/png"
    PNG_MIME_LEN     equ $ - PNG_MIME

    ICO_MIME         db "image/x-icon"
    ICO_MIME_LEN     equ $ - ICO_MIME

    ; ============================== Response Types ==============================
    RESPONSE_FILE  equ 0
    RESPONSE_EXEC  equ 1

    ; ============================== Methods ==============================
    GET    equ 0
    POST   equ 1
    PUT    equ 2
    DELETE equ 3

    ; ============================== File Locations ==============================
    get_fl_not_found db "templates/not_found.html", 0
    
    get_ep_ db "/", 0
    get_fl_ep_ db "templates/index.html", 0

    get_ep_index_html db "/index.html", 0
    get_fl_ep_index_html db "templates/index.html", 0

    get_ep_404 db "/404", 0
    get_fl_ep_404 db "templates/not_found.html", 0

    get_ep_about db "/about", 0
    get_fl_ep_about db "templates/about.html", 0

    get_ep_favicon_ico db "/favicon.ico", 0
    get_fl_ep_favicon_ico db "templates/favicon.ico", 0

    get_ep_style_css db "/style.css", 0
    get_fl_ep_style_css db "templates/style.css", 0

    post_ep_hello db "/hello", 0
    post_fl_ep_hello db "templates/post_responses/bin/hello", 0
    arg_ep_hello dq post_fl_ep_hello, 0

    post_ep_bye db "/bye", 0
    post_fl_ep_bye db "templates/post_responses/bye.sh", 0
    arg_ep_bye dq post_fl_ep_bye, 0


section .bss
    response_headers resb 512 

section .text
global process_file

%include "src/routing/fs.asm"
%include "src/functions.asm"

; ============================== process_file ==============================
; Checks if the path matches any of the files
; 
; If it does, it sends the file
; Arguments:
;   r10 holds the length of the path
;   rsi holds the path
process_file:
    cmp  r9, GET
    je   .get

    cmp  r9, POST
    je   .post

    .get:

        push rsi
        call f_process_file_ext
        pop  rsi
        mov  r11, RESPONSE_FILE
    
        .ep_:
            mov  rdi, get_ep_ 
            mov  rcx, r10
            call f_match_path
            cmp  rax, 1
            jne  .ep_index_html
            mov  rdi, get_fl_ep_ 
            ret
    
        .ep_index_html:
            mov  rdi, get_ep_index_html 
            mov  rcx, r10
            call f_match_path
            cmp  rax, 1
            jne  .ep_404
            mov  rdi, get_fl_ep_index_html 
            ret
    
        .ep_404:
            mov  rdi, get_ep_404 
            mov  rcx, r10
            call f_match_path
            cmp  rax, 1
            jne  .ep_about
            mov  rdi, get_fl_ep_404 
            ret
    
        .ep_about:
            mov  rdi, get_ep_about 
            mov  rcx, r10
            call f_match_path
            cmp  rax, 1
            jne  .ep_favicon_ico
            mov  rdi, get_fl_ep_about 
            ret
    
        .ep_favicon_ico:
            mov  rdi, get_ep_favicon_ico 
            mov  rcx, r10
            call f_match_path
            cmp  rax, 1
            jne  .ep_style_css
            mov  rdi, get_fl_ep_favicon_ico 
            ret
    
        .ep_style_css:
            mov  rdi, get_ep_style_css 
            mov  rcx, r10
            call f_match_path
            cmp  rax, 1
            jne  .not_found
            mov  rdi, get_fl_ep_style_css 
            ret
    
    .post:

        mov  r11, RESPONSE_EXEC
    
        .ep_hello:
            mov  rdi, post_ep_hello
            mov  rcx, r10
            call f_match_path
            cmp  rax, 1
            jne  .ep_bye
            lea  rdi, [post_fl_ep_hello]
            lea  rsi, [arg_ep_hello]
            lea  rdx, [NULL]
            ret
    
        .ep_bye:
            mov  rdi, post_ep_bye
            mov  rcx, r10
            call f_match_path
            cmp  rax, 1
            jne  .not_found
            lea  rdi, [post_fl_ep_bye]
            lea  rsi, [arg_ep_bye]
            lea  rdx, [NULL]
            ret
    
    .not_found:
        mov  rdi, get_fl_not_found
        mov  r9, HTTP_404
        mov  r8, HTTP_404_LEN
        mov  r11, RESPONSE_FILE
        ret
