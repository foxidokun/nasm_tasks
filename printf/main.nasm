%include "printf.nasm"
global own_printf_wrapper
; global _start
extern printf

segment .text

; ################################
; MAIN
; ################################
own_printf_wrapper:
    ; Convert stdcall to cdecl
    pop r12 ; Save return addr

    push r9 
    push r8 
    push rcx 
    push rdx 
    push rsi 
    push rdi

    call asm_printf

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop r8
    pop r9

    call printf

    push r12 ; Restore return addr
    ret

_start: 
    push 18446744073709551615
    push 18446744073709551615
    push 18446744073709551615
    push -1
    push helloworld
    push format_str
    call asm_printf

    mov rax, 60d
    mov rdi, 0d
    syscall
segment .data 

segment .rodata
format_str db "hello %s %d %o %a %x %b %q", newline, 0x00
helloworld db "Happy New Year", 0x00

segment .bss
registers_copy dq 6 dup(?)

;; SOME BASIC CONSTS
newline equ 0x0A