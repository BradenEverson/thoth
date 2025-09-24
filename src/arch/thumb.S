.section .text
.syntax unified
.thumb

.global context_switch
.type context_switch, %function
.thumb_func
context_switch:
    ldr r4, =1f
    str r4, [r1]
    str sp, [r0]
    mov sp, r2
    bx r3
1:
    bx lr

.global context_start
.type context_start, %function
.thumb_func
context_start:
    mov sp, r0
    bx r1
