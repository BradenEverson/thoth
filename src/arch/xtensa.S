.section .text

.global context_switch
.type context_switch, %function
context_switch:
    movi a6, 1f
    s32i a6, a2, 0
    
    s32i a12, a2, 48
    s32i a13, a2, 52
    s32i a14, a2, 56
    s32i a15, a2, 60
    s32i a8, a2, 64
    s32i a9, a2, 68
    s32i a10, a2, 72
    s32i a11, a2, 76
    
    s32i a1, a2, 40
    
    mov a1, a4
    
    l32i a12, a4, 48
    l32i a13, a4, 52
    l32i a14, a4, 56
    l32i a15, a4, 60
    l32i a8, a4, 64
    l32i a9, a4, 68
    l32i a10, a4, 72
    l32i a11, a4, 76
    
    jx a5

1:
    ret

.global context_start  
.type context_start, %function
context_start:
    mov a1, a2
    jx a3
