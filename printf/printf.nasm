%include "string.nasm"
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
; Dump buffer
; ################################
; Destroys: rbx
; ################################
dump_buffer:
    mov rbx, rsi
    sub rdi, buffer
    print_str buffer, rdi
    mov rsi, rbx
    mov rdi, buffer
ret


; ################################
; Format given string to stdout
; ################################
; CDECL 
; %1  -- format string addr like in std::printf
; %2+ -- %args
; Destroys: rax, rsi, rdi, rdx
; ################################
printf:
    xor rax, rax
    push rbp
    lea rbp, [rsp + 8*3] ; rbp -> first arg
    mov rsi, [rsp + 8*2] ; rsi = fmt string addr
    mov rdi, buffer

.loadsymbol:
    ; Check if buffer is full
    cmp rdi, buffer + BUFFER_SIZE
    jb .skip_writing_buffer

    ; Write buffer if full
    call dump_buffer

.skip_writing_buffer:
    ; Load symbol
    lodsb
    cmp al, '%'
    jne .not_percent

    ; Load modificator
    lodsb
    cmp al, '%'
    je .format_percent

    ; Jump table instead
    ; sub al, 'b'
    mov rdx, [rbp]
    lea rbp, [rbp + 8]
    call [(rax - "b") * 8 + call_table] ; jmp 
    jmp .loadsymbol

; Just copy symbols
.not_percent:
    test al, al
    jz .strend

    stosb
jmp .loadsymbol

; Dump buffer & exit
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

    ; There are only 64 bits in registers
    mov rcx, 64d

.format_prefix: ; skip leading zeros
    mov rbx, rdx
    rol rbx, 1
    and rbx, 1 ; Extract first bit

    test rbx, rbx ; Stop skipking if bit is non-zero
    jnz .format_digit
    
    shl rdx, 1
loop .format_prefix

    ; If number was 0 we should process one more bit
    test rcx, rcx
    jnz .format_digit
    inc rcx

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

    ; If number was 0 we should process one more bit
    test rcx, rcx
    jnz .format_digit
    inc rcx

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

    ; 64 = 21 * 3 + 1 => 21 block
    mov rcx, 21d

    ; Test highest bit
    mov rbx, rdx
    shl rdx, 1
    and rbx, HIGHER_BIT
    test rbx, rbx
    jz .format_prefix
    mov byte [rdi], '1'
    inc rdi

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

;; ####################################
;; # Format Char                      #
;; ####################################
;; # Args:                            #
;; # rdx -- char to format            #
;; # Return: rdi -> end of formatted  #
;; # string                           #
;; # Destroys: none                   #
;; ####################################
format_char:
    ; Just copy char to buffer
    mov [rdi], rdx
    inc rdi
ret

;; ####################################
;; # Format String                    #
;; ####################################
;; # Args:                            #
;; # rdx -- strptr to format          #
;; # Return: rdi -> end of formatted  #
;; # string                           #
;; # Destroys: r9, r10, r11           #
;; ####################################
format_string:
    ; Get strlen
    mov r11, rdi
    mov rdi, rdx
    call strlen
    mov rdi, r11

    ; Dump buffer if it is not empty
    cmp rdi, buffer
    je .skip_buffer_dump
        mov r9, rdx
        mov r10, rcx
        call dump_buffer
        mov rdx, r9
        mov rcx, r10

    ; Dump string
    .skip_buffer_dump:
        mov rbx, rsi
        mov r9, rdi
        print_str rdx, rcx
        mov rsi, rbx
        mov rdi, r9
ret

;; ####################################
;; # Format Decimal                   #
;; ####################################
;; # Args:                            #
;; # rdx -- num to format             #
;; # Return: rdi -> end of formatted  #
;; # string                           #
;; # Destroys:                        #
;; ####################################

format_decimal:
    push r13
    xor r13, r13

    mov rax, rdx ; Prepare for division
    mov rcx, 10 

    mov r9, rdi ; Save rdi

    shr rdx, 63
    test rdx, rdx
    jz .no_minus
        mov r13, 1
        not rax
        inc rax

.no_minus:
    mov rdi, dec_buffer + MAX_DEC_LEN - 1

.format_digit:
; Get one digit
    xor rdx, rdx
    div rcx

; Put it to buffer
    lea r11, [rdx + "0"]
    mov [rdi], r11b
    dec rdi

    test rax, rax
jnz .format_digit
    xchg rdi, r9
    inc r9

.copy_buf:
    test r13, r13
    jz .no_minus_buf
        mov byte [rdi], '-'
        inc rdi 

.no_minus_buf:
; Copy decimal buffer to global buffer
    mov al, [r9]
    mov [rdi], al
    inc r9
    inc rdi

    cmp r9, dec_buffer + MAX_DEC_LEN
    jb .no_minus_buf

    pop r13
ret


segment .rodata
    call_table dq format_binary
               dq format_char
               dq format_decimal
               dq 10 dup(0) ; default
               dq format_octo
               dq 3 dup(0)
               dq format_string
               dq 4 dup(0)
               dq format_hex
    
    hex_digits db "0123456789ABCDEF"

segment .bss

BUFFER_SIZE equ 0x100
RESERVED_SIZE equ 0x10
MAX_DEC_LEN equ 0x10

HIGHER_BIT equ 0x8000000000000000

buffer db BUFFER_SIZE + RESERVED_SIZE dup(?)
dec_buffer db MAX_DEC_LEN dup(?)
debug_buffer db MAX_DEC_LEN dup(?)