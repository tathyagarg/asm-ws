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

