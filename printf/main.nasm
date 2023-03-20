%include "printf.nasm"

global own_printf_wrapper
; global _start

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

    call printf

    add rsp, 6*8 ; Return stack pointer

    push r12 ; Restore return addr
    ret

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