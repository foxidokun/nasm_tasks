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
; Destroys: ax
; ################################
printf:
    xor rax, rax
    push rbp
    lea rbp, [rsp + 8*3] ; rbp -> first arg
    mov rsi, [rsp + 8*2] ; rdi = fmt string addr
    mov rdi, buffer

loadsymbol:
    lodsb
    cmp al, '%'
    jne .not_percent

    lodsb
    cmp al, '%'
    je .format_percent

    sub al, 'b'
    lea rbx, [rax + call_table]
    jmp [rbx]

.not_percent:
    test al, al
    jz .strend

    stosb
jmp loadsymbol

.strend:
    sub rdi, buffer

    print_str buffer, rdi
    pop rbp
    ret

;; Just put percent
.format_percent:
    stosb
jmp .loadsymbol



;; #############################
;; # Format binary             #
;; #############################
format_binary:
    ; Load argument
    mov rax, [rbp]
    lea rbp, [rbp + 8]

    ; Add '0b' before number
    mov word [rdi], '0b'
    lea rdi, [rdi + 2]

    ; Skip <= 63 bits
    mov rcx, 63d

.bin_format_prefix: ; skip leading zeros
    mov rbx, rax
    rol rbx, 1
    and rbx, 1 ; Extract first bit

    test rbx, rbx
    jnz .bin_format_digit
    
    shl rax, 1
loop .bin_format_prefix

.bin_format_digit:
    ; Get last bit
    shl rax, 1
    mov dl, [rbx + hex_digits]
    mov [rdi], dl
    inc rdi

    mov rbx, rax
    rol rbx, 1
    and rbx, 1
    test rax, rax
    jne .bin_format_digit  
jmp loadsymbol

segment .rodata
    call_table dq printf.format_binary
    
    hex_digits db "0123456789ABCDEF"

segment .bss

buffer db 0x100 dup(?)