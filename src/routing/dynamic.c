#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DATA                                                                   \
  "section .data\n"                                                            \
  "    ; ============= File Exts (Backwards) =============\n"                  \
  "    HTML_EXT     db      \"lmth\", 0h\n"                                    \
  "    HTML_EXT_LEN equ     $ - HTML_EXT\n"                                    \
  "\n"                                                                         \
  "    CSS_EXT      db      \"ssc\",  0h\n"                                    \
  "    CSS_EXT_LEN  equ     $ - CSS_EXT\n"                                     \
  "\n"                                                                         \
  "    JS_EXT       db      \"sj\",   0h\n"                                    \
  "    JS_EXT_LEN   equ     $ - JS_EXT\n"                                      \
  "\n"                                                                         \
  "    PNG_EXT      db      \"gnp\",  0h\n"                                    \
  "    PNG_EXT_LEN  equ     $ - PNG_EXT\n"                                     \
  "\n"                                                                         \
  "    ; ============= Responses ============\n"                               \
  "    html_http_200:\n"                                                       \
  "        db      \"HTTP/1.1 200 OK\",                      0dh, 0ah\n"       \
  "        db      \"Server: Tathya's Awesome Server\",      0dh, 0ah\n"       \
  "        db      \"Content-Type: text/html\",              0dh, 0ah\n"       \
  "        db                                              0dh, 0ah\n"         \
  "    html_http_200_len equ $ - html_http_200\n"                              \
  "\n"                                                                         \
  "    css_http_200:\n"                                                        \
  "        db      \"HTTP/1.1 200 OK\",                      0dh, 0ah\n"       \
  "        db      \"Server: Tathya's Awesome Server\",      0dh, 0ah\n"       \
  "        db      \"Content-Type: text/css\",               0dh, 0ah\n"       \
  "        db                                              0dh, 0ah\n"         \
  "    css_http_200_len equ $ - css_http_200\n"                                \
  "\n"                                                                         \
  "    js_http_200:\n"                                                         \
  "        db      \"HTTP/1.1 200 OK\",                      0dh, 0ah\n"       \
  "        db      \"Server: Tathya's Awesome Server\",      0dh, 0ah\n"       \
  "        db      \"Content-Type: application/javascript\", 0dh, 0ah\n"       \
  "        db                                              0dh, 0ah\n"         \
  "    js_http_200_len equ $ - js_http_200\n"                                  \
  "\n"                                                                         \
  "    png_http_200:\n"                                                        \
  "        db      \"HTTP/1.1 200 OK\",                      0dh, 0ah\n"       \
  "        db      \"Server: Tathya's Awesome Server\",      0dh, 0ah\n"       \
  "        db      \"Content-Type: image/png\",              0dh, 0ah\n"       \
  "        db                                              0dh, 0ah\n"         \
  "    png_http_200_len equ $ - png_http_200\n"                                \
  "\n"                                                                         \
  "    not_found_http_404:\n"                                                  \
  "        db      \"HTTP/1.1 404 Not Found\",               0dh, 0ah\n"         \
  "        db      \"Server: Tathya's Awesome Server\",      0dh, 0ah\n"         \
  "        db      \"Content-Type: text/html\",              0dh, 0ah\n"         \
  "        db                                              0dh, 0ah\n"         \
  "    not_found_http_404_len equ $ - not_found_http_404\n"                    \
  "    fl_not_found db \"templates/not_found.html\",         0h\n\n"           \

#define TEXT                                                                   \
  "section .text\n"                                                            \
  "global process_file\n"                                                      \
  "\n"                                                                         \
  "%%include 'src/routing/fs.asm'\n"                                           \
  "%%include 'src/functions.asm'\n"                                            \
  "\n"                                                                         \
  "; ============= Process File =============\n"                               \
  "; Checks if the path matches any of the files\n"                            \
  ";\n"                                                                        \
  "; If it does, it sends the file\n"                                          \
  "; r10 holds the length of the path\n"                                       \
  "; rsi holds the path\n"                                                     \
  "process_file:\n"                                                            \
  "    push rsi\n"                                                             \
  "    call f_process_file_ext\n"                                              \
  "    pop  rsi\n"                                                             \
  "\n"                                                             


#define WFILE "src/routing/routing.asm"
#define ROOT_FOLDER "templates"
#define MAXSIZE 1024

void write_data(FILE *wfile, FILE* rfile) {
    fprintf(wfile, DATA);
    char ep[MAXSIZE] = {0};
    char file_location[MAXSIZE] = {0};

    char eps[MAXSIZE][MAXSIZE] = {0};
    char file_locations[MAXSIZE][MAXSIZE] = {0};

    int line = 0;
    while (!feof(rfile)) {
        fscanf(rfile, "%s %s\n", ep, file_location);

        char ep_normalized[MAXSIZE] = {0};
        ep_normalized[0] = 'e';
        ep_normalized[1] = 'p';

        fprintf(wfile, "    ep");
        // Write the endpoint
        for (long unsigned int i = 0; i < sizeof(ep) / sizeof(char); i++) {
            if (ep[i] == '\0') {
                break;
            }
            char curr = ep[i] == '/' || ep[i] == '.' ? '_' : ep[i];
            ep_normalized[i + 2] = curr;

            fprintf(wfile, "%c", curr);
        }

        fprintf(wfile, "     db \"%s\", 0h\n", ep);

        char curr_file_location[MAXSIZE] = {0};
        curr_file_location[0] = 'f';
        curr_file_location[1] = 'l';
        curr_file_location[2] = '_';
        strcpy(curr_file_location + 3, ep_normalized);

        fprintf(wfile, "    %s", curr_file_location);
        fprintf(wfile, "     db \"%s/%s\", 0h\n\n", ROOT_FOLDER, file_location);

        strcpy(eps[line], ep_normalized);
        strcpy(file_locations[line], curr_file_location);

        line++;
    }
    strcpy(eps[line], "not_found");
    strcpy(file_locations[line], "fl_not_found");

    fprintf(wfile, TEXT);

    for (int i = 0; i <= line; i++) {
        fprintf(wfile, "    .%s:\n", eps[i]);
        if (i == line) {
            fprintf(wfile, "        mov  rdi, fl_not_found\n");
            fprintf(wfile, "        mov  r9, not_found_http_404\n");
            fprintf(wfile, "        mov  r8, not_found_http_404_len\n");
        } else {
            fprintf(wfile, "        mov  rdi, %s\n", eps[i]);
            fprintf(wfile, "        mov  rcx, r10\n");
            fprintf(wfile, "        call f_match_path\n");
            fprintf(wfile, "        cmp  rax, 1\n");
            fprintf(wfile, "        jne  .%s\n", eps[i + 1]);
            fprintf(wfile, "        mov  rdi, %s\n", file_locations[i]);
        }
        fprintf(wfile, "        ret\n\n");
    }
}

int main() {
    FILE* wfile = fopen(WFILE, "w");
    if (wfile == NULL) {
        printf("Error opening write file!\n");
        exit(1);
    }

    FILE* rfile = fopen("src/routing/.endpoints", "r");
    if (rfile == NULL) {
        printf("Error opening read file!\n");
        exit(1);
    }

    write_data(wfile, rfile);
    return 0;
}
