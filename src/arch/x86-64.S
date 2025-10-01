.section .text

.global context_switch
context_switch:
    leaq 1f(%rip), %rax
    movq %rax, (%rsi)
    movq %rsp, (%rdi)
    movq %rdx, %rsp
    jmp *%rcx
1:
    ret

.global context_start
context_start:
    mov %rdi, %rsp
    jmp *%rsi
