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

    JSON_EXT      db "nosj", 0
    JSON_EXT_LEN  equ $ - JSON_EXT

    OS_EXT        db "o", 0
    OS_EXT_LEN    equ $ - OS_EXT

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

    JSON_MIME        db "application/json"
    JSON_MIME_LEN    equ $ - JSON_MIME

    OS_MIME          db "application/octet-stream"
    OS_MIME_LEN      equ $ - OS_MIME

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
    get_len_ep_ equ $ - get_ep_
    get_fl_ep_ db "templates/index.html", 0
    get_len_fl_ep_ equ $ - get_fl_ep_

    get_ep_index_html db "/index.html", 0
    get_len_ep_index_html equ $ - get_ep_index_html
    get_fl_ep_index_html db "templates/index.html", 0
    get_len_fl_ep_index_html equ $ - get_fl_ep_index_html

    get_ep_404 db "/404", 0
    get_len_ep_404 equ $ - get_ep_404
    get_fl_ep_404 db "templates/not_found.html", 0
    get_len_fl_ep_404 equ $ - get_fl_ep_404

    get_ep_about db "/about", 0
    get_len_ep_about equ $ - get_ep_about
    get_fl_ep_about db "templates/about.html", 0
    get_len_fl_ep_about equ $ - get_fl_ep_about

    get_ep_favicon_ico db "/favicon.ico", 0
    get_len_ep_favicon_ico equ $ - get_ep_favicon_ico
    get_fl_ep_favicon_ico db "templates/favicon.ico", 0
    get_len_fl_ep_favicon_ico equ $ - get_fl_ep_favicon_ico

    get_ep_style_css db "/style.css", 0
    get_len_ep_style_css equ $ - get_ep_style_css
    get_fl_ep_style_css db "templates/style.css", 0
    get_len_fl_ep_style_css equ $ - get_fl_ep_style_css

    get_ep_hi db "/hi", 0
    get_len_ep_hi equ $ - get_ep_hi
    get_fl_ep_hi db "templates/post_responses/bin/hello.o", 0
    get_len_fl_ep_hi equ $ - get_fl_ep_hi

    post_ep_bye db "/bye", 0
    post_len_ep_bye equ $ - post_ep_bye
    post_fl_ep_bye db "templates/post_responses/bye.sh", 0
    post_len_fl_ep_bye equ $ - post_fl_ep_bye
    arg_ep_bye dq post_fl_ep_bye, 0
    resp_ep_bye db "templates/post_responses/bin/hello.o", 0
    resp_mime_ep_bye equ OS_MIME
    resp_mime_len_ep_bye equ OS_MIME_LEN


section .bss
    response_headers resb 512 

section .text

%include "src/routing/fs.asm"
%include "src/functions.asm"

global process_file, make_headers

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

        mov  r11, RESPONSE_FILE
    
        .ep_:
            mov  rdi, get_ep_ 
            mov  rcx, get_len_ep_
            call f_match_path
            cmp  rax, 1
            jne  .ep_index_html
            mov  rdi, get_fl_ep_ 
            mov  r10, get_len_fl_ep_
            jmp  .get_done
    
        .ep_index_html:
            mov  rdi, get_ep_index_html 
            mov  rcx, get_len_ep_index_html
            call f_match_path
            cmp  rax, 1
            jne  .ep_404
            mov  rdi, get_fl_ep_index_html 
            mov  r10, get_len_fl_ep_index_html
            jmp  .get_done
    
        .ep_404:
            mov  rdi, get_ep_404 
            mov  rcx, get_len_ep_404
            call f_match_path
            cmp  rax, 1
            jne  .ep_about
            mov  rdi, get_fl_ep_404 
            mov  r10, get_len_fl_ep_404
            jmp  .get_done
    
        .ep_about:
            mov  rdi, get_ep_about 
            mov  rcx, get_len_ep_about
            call f_match_path
            cmp  rax, 1
            jne  .ep_favicon_ico
            mov  rdi, get_fl_ep_about 
            mov  r10, get_len_fl_ep_about
            jmp  .get_done
    
        .ep_favicon_ico:
            mov  rdi, get_ep_favicon_ico 
            mov  rcx, get_len_ep_favicon_ico
            call f_match_path
            cmp  rax, 1
            jne  .ep_style_css
            mov  rdi, get_fl_ep_favicon_ico 
            mov  r10, get_len_fl_ep_favicon_ico
            jmp  .get_done
    
        .ep_style_css:
            mov  rdi, get_ep_style_css 
            mov  rcx, get_len_ep_style_css
            call f_match_path
            cmp  rax, 1
            jne  .ep_hi
            mov  rdi, get_fl_ep_style_css 
            mov  r10, get_len_fl_ep_style_css
            jmp  .get_done
    
        .ep_hi:
            mov  rdi, get_ep_hi 
            mov  rcx, get_len_ep_hi
            call f_match_path
            cmp  rax, 1
            jne  .not_found
            mov  rdi, get_fl_ep_hi 
            mov  r10, get_len_fl_ep_hi
            jmp  .get_done
    
        .get_done:
            mov  rsi, rdi
            push rdi
            call f_process_file_ext
            pop  rdi
            ret
    .post:

        mov  r11, RESPONSE_EXEC
    
        .ep_bye:
            mov  rdi, post_ep_bye
            mov  rcx, r10
            call f_match_path
            cmp  rax, 1
            jne  .not_found
            lea  rdi, [post_fl_ep_bye]
            lea  rsi, [arg_ep_bye]
            lea  rdx, [NULL]
            mov  r9, resp_ep_bye
            mov  r8, resp_mime_ep_bye
            mov  r10, resp_mime_len_ep_bye
            ret
    
    .not_found:
        mov  rdi, get_fl_not_found
        mov  r9, HTTP_404
        mov  r8, HTTP_404_LEN
        mov  r11, RESPONSE_FILE
        ret
