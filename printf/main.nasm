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
    pop qword [ret_addr] ; Save return addr

    push r9 
    push r8 
    push rcx 
    push rdx 
    push rsi 
    push rdi

    push 26
    push func_name_str
    push format_str
    call asm_printf
    add rsp, 8*3

    call asm_printf

    mov rdi, format_str
    mov rsi, func_name_str
    mov rdx, 26
    call printf

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop r8
    pop r9

    call printf

    push qword [ret_addr] ; Restore return addr
    ret

_start: 
    push 18446744073709551615
    push 18446744073709551615
    push 18446744073709551615
    push -1
    push main_func_str
    push format_str
    call asm_printf

    mov rax, 60d
    mov rdi, 0d
    syscall

segment .data 
ret_addr        dq 1 dup(0)

segment .rodata
format_str      db "## hello you called func %s on line %d ##", newline, newline, 0x00
func_name_str   db "own_printf_wrapper", 0x00
main_func_str   db "MAIN"

segment .bss
registers_copy dq 6 dup(?)

;; SOME BASIC CONSTS
newline equ 0x0A