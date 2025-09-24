.section .text

.global context_switch
.type context_switch, %function
context_switch:
    adr x8, 1f
    str x8, [x1]
    str sp, [x0]
    mov sp, x2
    br x3
1:
    ret

.global context_start
.type context_start, %function
context_start:
    mov sp, x0
    br x1
