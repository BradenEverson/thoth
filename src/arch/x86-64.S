.section .text

.global context_switch
context_switch:
    leaq 1f(%rip), %rax
    movq %rax, (%rsi)
    
    movq %rbx, 32(%rdi)
    movq %rbp, 40(%rdi) 
    movq %r12, 48(%rdi)
    movq %r13, 56(%rdi)
    movq %r14, 64(%rdi)
    movq %r15, 72(%rdi)
    movq %rsp, (%rdi)
    
    movq %rdx, %rsp
    
    movq 32(%rdx), %rbx
    movq 40(%rdx), %rbp
    movq 48(%rdx), %r12
    movq 56(%rdx), %r13
    movq 64(%rdx), %r14
    movq 72(%rdx), %r15
    
    jmp *%rcx

1:
    ret

.global context_start
context_start:
    movq %rdi, %rsp
    jmp *%rsi
