.section .text
.syntax unified
.arm

.global context_switch
.type context_switch, %function
context_switch:
    ldr r12, =1f
    str r12, [r1]
    
    str r4, [r0, #12]
    str r5, [r0, #16]
    str r6, [r0, #20]
    str r7, [r0, #24]
    str r8, [r0, #28]
    str r9, [r0, #32]
    str r10, [r0, #36]
    str r11, [r0, #40]
    str sp, [r0]
    str lr, [r0, #44]
    
    mov sp, r2
    
    ldr r4, [r2, #12]
    ldr r5, [r2, #16]
    ldr r6, [r2, #20]
    ldr r7, [r2, #24]
    ldr r8, [r2, #28]
    ldr r9, [r2, #32]
    ldr r10, [r2, #36]
    ldr r11, [r2, #40]
    ldr lr, [r2, #44]
    
    bx r3

1:
    bx lr

.global context_start
.type context_start, %function
context_start:
    mov sp, r0
    bx r1
