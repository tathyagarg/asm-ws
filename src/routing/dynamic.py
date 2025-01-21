import re
import sys
from collections import defaultdict
from dataclasses import dataclass
from enum import Enum

templates_dir = sys.argv[1] if len(sys.argv) > 1 else "templates"

RFILE = f"{templates_dir}/.endpoints"
WFILE = "src/routing/routing.asm"

DATA = f"""section .data
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

    TTF_EXT        db "ttf", 0
    TTF_EXT_LEN    equ $ - TTF_EXT

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

TEXT = """
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


def parser(rfile):
    with open(rfile, "r") as f:
        lines = f.readlines()

    routes: dict[str, list[Route]] = defaultdict(list)
    curr_method: Method | None = None
    with open(WFILE, "w") as f:
        f.write(DATA)

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

        f.write(TEXT)
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


parser(RFILE)
