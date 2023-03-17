%include "printf.nasm"

global _start

segment .text

; ################################
; MAIN
; ################################

_start: 
    push 228
    push 228
    push 228
    push helloworld
    call printf

    mov rax, 60d
    mov rdi, 0d
    syscall
segment .data 

segment .rodata
format_str db "lets test %x"

helloworld db "hello %b %x world", newline, 0x00
helloworld_len equ $ - helloworld


;; SOME BASIC CONSTS
newline equ 0x0A