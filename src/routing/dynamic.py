import re
import sys
from collections import defaultdict
from dataclasses import dataclass
from enum import Enum

templates_dir = sys.argv[1] if len(sys.argv) > 1 else "templates"

RFILE = f"{templates_dir}/.endpoints"
ROUTING_WFILE = "src/routing/routing.asm"
FS_WFILE = "src/routing/fs.asm"

ROUTING_DATA = f"""section .data
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

    O_EXT         db "o", 0
    O_EXT_LEN     equ $ - O_EXT

    SVG_EXT       db "gvs", 0
    SVG_EXT_LEN   equ $ - SVG_EXT

    TTF_EXT       db "ftt", 0
    TTF_EXT_LEN   equ $ - TTF_EXT

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

    O_MIME           db "application/octet-stream"
    O_MIME_LEN       equ $ - O_MIME

    SVG_MIME         db "image/svg+xml"
    SVG_MIME_LEN     equ $ - SVG_MIME

    TTF_MIME         db "font/ttf"
    TTF_MIME_LEN     equ $ - TTF_MIME

    ; ============================== Response Types ==============================
    RESPONSE_FILE  equ 0
    RESPONSE_EXEC  equ 1

    ; ============================== Methods ==============================
    GET    equ 0
    POST   equ 1
    PUT    equ 2
    DELETE equ 3

    ; ============================== File Locations ==============================
    get_fl_not_found db "{templates_dir}/not_found.html", 0
    
"""

ROUTING_TEXT = f"""
section .bss
    response_headers resb 512 

section .text

%include "{FS_WFILE}"
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

"""

FS_TEXT = """; ========== Match Path ==========
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

; ========== Process File Extension ==========
; Determines the HTTP Headers of the file based on the file extension
;
; Returns the HTTP Headers in r9 and the length in r8
; File name is passed in in r10
f_process_file_ext:
"""


class Method(Enum):
    GET = 0
    POST = 1
    PUT = 2
    DELETE = 3

    def __str__(self):
        return self.name.lower()


HEADERS = {
    "get": """
        mov  r11, RESPONSE_FILE
    """,
    "post": """
        mov  r11, RESPONSE_EXEC
    """,
}

EP_FORMATS = {
    "get": """
            mov  rdi, get_{ep} 
            mov  rcx, get_len_{ep}
            call f_match_path
            cmp  rax, 1
            jne  .{next_ep}
            mov  rdi, get_{fl} 
            mov  r10, get_len_{fl}
            jmp  .get_done
    """,
    "post": """
            mov  rdi, post_{ep}
            mov  rcx, r10
            call f_match_path
            cmp  rax, 1
            jne  .{next_ep}
            lea  rdi, [post_{fl}]
            lea  rsi, [arg_{ep}]
            lea  rdx, [NULL]
            mov  r9, resp_{ep}
            mov  r8, resp_mime_{ep}
            mov  r10, resp_mime_len_{ep}
            ret
    """,
}

METHOD_PREFIXES = {
    "get": templates_dir,
    "post": f"{templates_dir}/post_responses",
}


@dataclass
class Route:
    method: Method
    ep: str
    file_location: str


def routing_parser(rfile):
    with open(rfile, "r") as f:
        lines = f.readlines()

    routes: dict[str, list[Route]] = defaultdict(list)
    curr_method: Method | None = None
    with open(ROUTING_WFILE, "w") as f:
        f.write(ROUTING_DATA)

        for line in lines:
            if line.startswith("#"):
                continue

            line = line.strip()
            if m := re.match(r"^(GET|POST|PUT|DELETE)$", line):
                curr_method = Method[m.group(0)]
                continue

            if not line:
                continue

            if curr_method == Method.POST:
                ep, file_location, response, rt = line.split(" ")
            else:
                ep, file_location = line.split(" ")
                response = rt = None  # To make pyright shut up

            ep_normalized = "ep" + ep.replace("/", "_").replace(".", "_")
            fl_normalized = "fl_" + ep_normalized

            f.write(f'    {curr_method!s}_{ep_normalized} db "{ep}", 0\n')
            f.write(
                f"    {curr_method!s}_len_{ep_normalized} equ $ - {curr_method!s}_{ep_normalized}\n"
            )
            f.write(
                f'    {curr_method!s}_{fl_normalized} db "{METHOD_PREFIXES[str(curr_method)]}/{file_location}", 0\n'
            )
            f.write(
                f"    {curr_method!s}_len_{fl_normalized} equ $ - {curr_method!s}_{fl_normalized}\n"
            )
            if curr_method == Method.POST:
                f.write(
                    f"    arg_{ep_normalized} dq {curr_method!s}_{fl_normalized}, 0\n"
                )
                f.write(f'    resp_{ep_normalized} db "{response}", 0\n')
                f.write(f"    resp_mime_{ep_normalized} equ {rt}_MIME\n")
                f.write(f"    resp_mime_len_{ep_normalized} equ {rt}_MIME_LEN\n\n")
            else:
                f.write("\n")

            if not curr_method:
                raise ValueError("No method found")
            routes[str(curr_method)].append(
                Route(curr_method, ep_normalized, fl_normalized)
            )

        f.write(ROUTING_TEXT)
        for method, curr_routes in routes.items():
            f.write(f"    .{method}:\n")
            f.write(HEADERS[method])
            f.write("\n")
            for i, route in enumerate(curr_routes):
                ep, fl = route.ep, route.file_location
                next_ep = (
                    curr_routes[i + 1].ep if i + 1 < len(curr_routes) else "not_found"
                )

                f.write(f"        .{ep}:")
                f.write(EP_FORMATS[method].format(ep=ep, fl=fl, next_ep=next_ep))
                f.write("\n")

            if method == Method.GET.name.lower():
                f.write(f"        .get_done:\n")
                f.write(f"            mov  rsi, rdi\n")
                f.write(f"            push rdi\n")
                f.write(f"            call f_process_file_ext\n")
                f.write(f"            pop  rdi\n")
                f.write(f"            ret\n")

        if str(Method.GET) not in routes:
            f.write(f"    .get:\n")
            f.write(f"        jmp  .not_found\n")

        if str(Method.POST) not in routes:
            f.write(f"    .post:\n")
            f.write(f"        jmp  .not_found\n")

        f.write(f"    .not_found:\n")
        f.write(f"        mov  rdi, get_fl_not_found\n")
        f.write(f"        mov  r9, HTTP_404\n")
        f.write(f"        mov  r8, HTTP_404_LEN\n")
        f.write(f"        mov  r11, RESPONSE_FILE\n")
        f.write(f"        ret\n")


def fs_parser(rfile: str):
    file_exts: set[str] = set()
    with open(rfile) as f:
        lines = f.readlines()
        for line in lines:
            if (
                not line.strip()
                or line.startswith("#")
                or re.match(r"^(GET|POST|PUT|DELETE)$", line)
            ):
                continue

            file_exts.add(line.strip().rsplit(".", 1)[1].split(" ")[0])

    with open(FS_WFILE, "w") as f:
        f.write(FS_TEXT)
        for ext in file_exts:
            f.write(f"    mov  rdi, {ext.upper()}_EXT\n")
            f.write(f"    mov  rcx, r10\n")
            f.write(f"    mov  r9, {ext.upper()}_EXT_LEN\n")
            f.write(f"    call f_match_file_ext\n")
            f.write(f"    cmp  rax, 1\n")
            f.write(f"    je   .{ext}\n\n")

        f.write(f"    mov  rdi, NO_EXT\n")
        f.write(f"    mov  rcx, r10\n")
        f.write(f"    mov  r9, NO_EXT_LEN\n")
        f.write(f"    call f_match_file_ext\n")
        f.write(f"    cmp  rax, 1\n")
        f.write(f"    jne  .not_found\n\n")
        for ext in file_exts:
            f.write(f"    .{ext}:\n")
            f.write(f"        mov  r9, {ext.upper()}_MIME\n")
            f.write(f"        mov  r8, {ext.upper()}_MIME_LEN\n")
            f.write(f"        jmp  .found\n\n")

        f.write(f"    .found:\n")
        f.write(f"        call make_headers\n")
        f.write(f"        ret\n\n")
        f.write(f"    .not_found:\n")
        f.write(f"        mov  r9, HTTP_404\n")
        f.write(f"        mov  r8, HTTP_404_LEN\n")
        f.write(f"        ret\n")


routing_parser(RFILE)
fs_parser(RFILE)
