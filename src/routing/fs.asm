; ========== Match Path ==========
; Compares the path in [path] to the given path
;
; Returns 1 if the paths match, 0 otherwise
; Path to match is passed in in rdi
; Path to match against is in [path]
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
        pop  rsi
        mov  rax, 1
        ret

    .no_match:
        pop  rsi
        mov  rax, 0
        ret
    
