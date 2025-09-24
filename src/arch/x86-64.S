.section .text

.global context_switch
.type context_switch, @function
context_switch:
    leaq 1f(%rip), %rax
    movq %rax, (%rsi)
    movq %rsp, (%rdi)
    movq %rdx, %rsp
    jmp *%rcx
1:
    ret

.global context_start
.type context_start, @function
context_start:
    mov %rdi, %rsp
    jmp *%rsi
