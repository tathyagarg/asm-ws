import re
from dataclasses import dataclass
from enum import Enum

RFILE = "templates/.endpoints"
WFILE = "src/routing/routing.asm"

DATA = """section .data
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
    
"""

TEXT = """
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
        push rsi
        call f_process_file_ext
        pop  rsi
        mov  r11, RESPONSE_FILE
    """,
    "post": """
        mov  r11, RESPONSE_EXEC
    """,
}

EP_FORMATS = {
    "get": """
            mov  rdi, {ep} 
            mov  rcx, r10
            call f_match_path
            cmp  rax, 1
            jne  .{next_ep}
            mov  rdi, {fl} 
            ret
    """,
    "post": """
            mov  rdi, {ep}
            mov  rcx, r10
            call f_match_path
            cmp  rax, 1
            jne  .{next_ep}
            lea  rdi, [{fl}]
            lea  rsi, [arg_{ep}]
            lea  rdx, [NULL]
            ret
    """,
}

METHOD_PREFIXES = {
    "get": "templates/",
    "post": "templates/post_responses/",
}


@dataclass
class Route:
    method: Method
    ep: str
    file_location: str


def parser(rfile):
    with open(rfile, "r") as f:
        lines = f.readlines()

    routes: dict[str, list[Route]] = {}
    curr_method: Method | None = None
    with open(WFILE, "w") as f:
        f.write(DATA)

        for line in lines:
            line = line.strip()
            if m := re.match(r"^(GET|POST|PUT|DELETE)$", line):
                curr_method = Method[m.group(0)]
                continue

            ep, file_location = line.split(" ")

            ep_normalized = "ep" + ep.replace("/", "_").replace(".", "_")
            fl_normalized = "fl_" + ep_normalized

            f.write(f'    {curr_method!s}_{ep_normalized} db "{ep}", 0\n')
            f.write(
                f'    {curr_method!s}_{fl_normalized} db "{METHOD_PREFIXES[str(curr_method)]}/{file_location}", 0\n\n'
            )
            if curr_method == Method.POST:
                f.write(
                    f"    arg_{ep_normalized} db {curr_method!s}_{fl_normalized}, 0\n"
                )

            if not curr_method:
                raise ValueError("No method found")
            routes[str(curr_method)].append(Route(curr_method, ep, file_location))

        f.write(TEXT)
        for method, curr_routes in routes.items():
            f.write(f"    .{method}:\n")
            f.write(HEADERS[method])
            for i, route in enumerate(curr_routes):
                ep, fl = route.ep, route.file_location
                next_ep = (
                    curr_routes[i + 1].ep if i + 1 < len(curr_routes) else "not_found"
                )

                f.write(f"    .{ep}:\n")
                f.write(EP_FORMATS[method].format(ep=ep, fl=fl, next_ep=next_ep))

            f.write(f"    .not_found:\n")
            f.write(f"        mov  rdi, fl_not_found\n")
            f.write(f"        mov  r9, HTTP_404\n")
            f.write(f"        mov  r8, HTTP_404_LEN\n")
            f.write(f"        mov  r11, RESPONSE_FILE\n")
            f.write(f"        ret\n")


parser(RFILE)
