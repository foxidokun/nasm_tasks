%include "printf.nasm"

global _start

segment .text

; ################################
; MAIN
; ################################

_start: 
    push 0
    push 0
    push 0
    push 0
    push helloworld
    push format_str
    call printf

    mov rax, 60d
    mov rdi, 0d
    syscall
segment .data 

segment .rodata
format_str db "hello %s %d %o %x %b", newline, 0x00
helloworld db "Happy New Year", 0x00


;; SOME BASIC CONSTS
newline equ 0x0A