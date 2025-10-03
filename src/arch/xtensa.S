.section .text

.global context_switch
.type context_switch, %function
context_switch:
    movi a6, 1f
    s32i a6, a3, 0
    
    s32i a12, a2, 12
    s32i a13, a2, 16  
    s32i a14, a2, 20
    s32i a15, a2, 24
    s32i a8, a2, 28
    s32i a9, a2, 32
    s32i a10, a2, 36
    s32i a11, a2, 40
    
    s32i a1, a2, 0
    
    mov a1, a4
    
    l32i a12, a4, 12
    l32i a13, a4, 16
    l32i a14, a4, 20
    l32i a15, a4, 24
    l32i a8, a4, 28
    l32i a9, a4, 32
    l32i a10, a4, 36
    l32i a11, a4, 40
    
    jx a5

1:
    ret

.global context_start
.type context_start, %function
context_start:
    mov a1, a2
    jx a3
