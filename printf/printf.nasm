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

.loadsymbol:
    lodsb
    cmp al, '%'
    jne .not_percent

    lodsb
    cmp al, '%'
    je .format_percent

    sub al, 'b'
    mov rdx, [rbp]
    lea rbp, [rbp + 8]
    call [rax * 8 + call_table]
    jmp .loadsymbol

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
.format_percent:
    stosb
jmp .loadsymbol

;; ####################################
;; # Format Binary                    #
;; ####################################
;; # Args:                            #
;; # rdx -- number to format          #
;; # rdi -- pointer to buffer         #
;; # Destroys: (rdx), rbx, rcx, (rdi) #
;; ####################################
format_binary:
    ; Add '0b' before number
    mov word [rdi], '0b'
    lea rdi, [rdi + 2]

    ; Skip <= 63 bits
    mov rcx, 64d

.format_prefix: ; skip leading zeros
    mov rbx, rdx
    rol rbx, 1
    and rbx, 1 ; Extract first bit

    test rbx, rbx ; Stop skipking if bit is non-zero
    jnz .format_digit
    
    shl rdx, 1
loop .format_prefix

.format_digit:
    ; Write digit
    lea rbx, [rbx + '0']
    mov [rdi], bl
    inc rdi

    ; Update last bit
    shl rdx, 1
    mov rbx, rdx
    rol rbx, 1
    and rbx, 1
    loop .format_digit  
ret

;; ####################################
;; # Format Hex                       #
;; ####################################
;; # Args:                            #
;; # rdx -- number to format          #
;; # rdi -- pointer to buffer         #
;; # Return: rdi -> end of formatted  #
;; # string                           #
;; # Destroys: (rdx), rbx, rcx, (rdi) #
;; ####################################
format_hex:
    ; Add '0x' before number
    mov word [rdi], '0x'
    lea rdi, [rdi + 2]

    ; 64 / 8 = 16 blocks
    mov rcx, 16d

.format_prefix: ; skip leading zeros
    mov rbx, rdx
    rol rbx, 4
    and rbx, 0xF ; Extract first block

    test rbx, rbx ; Stop skipking if block is non-zero
    jnz .format_digit
    
    shl rdx, 4
loop .format_prefix

.format_digit:
    ; Write digit
    mov bl, [rbx + hex_digits]
    mov [rdi], bl
    inc rdi

    ; Update last octet
    shl rdx, 4
    mov rbx, rdx
    rol rbx, 4
    and rbx, 0xF
    loop .format_digit  
ret

;; ####################################
;; # Format Octo                      #
;; ####################################
;; # Args:                            #
;; # rdx -- number to format          #
;; # rdi -- pointer to buffer         #
;; # Return: rdi -> end of formatted  #
;; # string                           #
;; # Destroys: (rdx), rbx, rcx, (rdi) #
;; ####################################
format_octo:
    ; Add '0o' before number
    mov word [rdi], '0o'
    lea rdi, [rdi + 2]

    ; Skip <= 21 blocks
    mov rcx, 22d

.format_prefix: ; skip leading zeros
    mov rbx, rdx
    rol rbx, 3
    and rbx, 0x7 ; Extract first block

    test rbx, rbx ; Stop skipking if block is non-zero
    jnz .format_digit
    
    shl rdx, 3
loop .format_prefix

.format_digit:
    ; Write digit
    lea rbx, [rbx + '0']
    mov [rdi], bl
    inc rdi

    ; Update last octet
    shl rdx, 3
    mov rbx, rdx
    rol rbx, 3
    and rbx, 0x7
    test rdx, rdx
    jne .format_digit  
ret

segment .rodata
    call_table dq format_binary
               dq 12 dup(0)
               dq format_octo
               dq 8 dup(0)
               dq format_hex
    
    hex_digits db "0123456789ABCDEF"

segment .bss

buffer db 0x100 dup(?)