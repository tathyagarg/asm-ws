RFILE = "templates/.endpoints"
WFILE = "src/routing/routing.asm"

DATA = """section .data
    ; ============================== File Extensions ==============================
    HTML_EXT db "lmth", 0
    HTML_EXT_LEN equ $ - HTML_EXT

    CSS_EXT db "ssc", 0
    CSS_EXT_LEN equ $ - CSS_EXT

    JS_EXT db "sj", 0
    JS_EXT_LEN equ $ - JS_EXT

    PNG_EXT db "gnp", 0
    PNG_EXT_LEN equ $ - PNG_EXT

    ICO_EXT db "oci", 0
    ICO_EXT_LEN equ $ - ICO_EXT

    NO_EXT db "/", 0
    NO_EXT_LEN equ $ - NO_EXT

    ; ============================== Responses ==============================
    HTTP_200:
        db "HTTP/1.1 200 OK",                          0dh, 0ah
        db "Server: Tathya's Awesome Assembly Server", 0dh, 0ah
        db                                             0h
    HTTP_200_LEN equ $ - HTTP_200

    HTTP_404:
        db "HTTP/1.1 404 Not Found",                   0dh, 0ah
        db "Server: Tathya's Awesome Assembly Server", 0dh, 0ah
        db                                             0h
    HTTP_404_LEN equ $ - HTTP_404

    Content_Type db "Content-Type: ", 0
    Content_Type_LEN equ $ - Content_Type

    HTML_MIME db "text/html", 0
    HTML_MIME_LEN equ $ - HTML_MIME

    CSS_MIME db "text/css", 0
    CSS_MIME_LEN equ $ - CSS_MIME

    JS_MIME db "application/javascript", 0
    JS_MIME_LEN equ $ - JS_MIME

    PNG_MIME db "image/png", 0
    PNG_MIME_LEN equ $ - PNG_MIME

    ICO_MIME db "image/x-icon", 0
    ICO_MIME_LEN equ $ - ICO_MIME

    ; ============================== File Locations ==============================
    fl_not_found db "templates/not_found.html", 0
    
"""

TEXT = """
section .bss
    response_headers resb 256

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
    push rsi
    call f_process_file_ext
    pop rsi

"""


def parser(rfile):
    with open(rfile, "r") as f:
        lines = f.readlines()

    with open(WFILE, "w") as f:
        f.write(DATA)
        eps: list[str] = []
        fls: list[str] = []

        for line in lines:
            line = line.strip()

            ep, file_location = line.split(" ")

            ep_normalized = "ep" + ep.replace("/", "_").replace(".", "_")
            fl_normalized = "fl_" + ep_normalized

            f.write(f'    {ep_normalized} db "{ep}", 0\n')
            f.write(f'    {fl_normalized} db "templates/{file_location}", 0\n\n')

            eps.append(ep_normalized)
            fls.append(fl_normalized)

        f.write(TEXT)
        for i, (ep, fl) in enumerate(zip(eps, fls)):
            next_ep = eps[i + 1] if i + 1 < len(eps) else "not_found"

            f.write(f"    .{ep}:\n")
            f.write(f"        mov  rdi, {ep}\n")
            f.write(f"        mov  rcx, r10\n")
            f.write(f"        call f_match_path\n")
            f.write(f"        cmp  rax, 1\n")
            f.write(f"        jne  .{next_ep}\n")
            f.write(f"        mov  rdi, {fl}\n")
            f.write(f"        ret\n\n")

        f.write(f"    .not_found:\n")
        f.write(f"        mov  rdi, fl_not_found\n")
        f.write(f"        mov  r9, HTTP_404\n")
        f.write(f"        mov  r8, HTTP_404_LEN\n")
        f.write(f"        ret\n")


parser(RFILE)
