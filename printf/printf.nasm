segment .text

; ################################
; Write given string to stdout
; ################################
;   %1 -- string ptr
;   %2 -- string size
; Destroys: rax, rsi, rdi, rdx
; ################################
%macro print_str 2
    mov rax, 0x01
    mov rsi, %1
    mov rdx, %2
    mov rdi, 1
    syscall
%endmacro

; ################################
; Format given string to stdout
; ################################
; CDECL 
; %1  -- format string addr like in std::printf
; %2+ -- %args
; Destroys: 
; ################################
printf:
    push rbp
    lea rbp, [rsp + 16] ; rbp -> first arg
    mov rsi, [rsp + 16] ; rdi = fmt string addr
    mov rdi, buffer

.loadsymbol:
    lodsb
    cmp al, '%'
    jne .not_percent

    lodsb
    cmp al, '%'
    je .format_percent

.not_percent:
    test al, al
    jz .strend

    stosb
jmp .loadsymbol

.strend:
    sub rdi, buffer

    print_str buffer, rdi
    pop rbp
    ret

;; Just put percent
.format_percent
    stosb
jmp .loadsymbol

segment .rodata
    call_table dq 

segment .bss

buffer db 0x100 dup(?)