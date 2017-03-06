addi r3, r0, 5
addi r2, r0, 10
addi r4, r0, 2sw 10(r2), r3
addi r7, r0, 1
addi r8, r0, 1
addi r9, r0, 1
lw r3, 0(r2)
jal ciao
addi r7, r0, 1
addi r8, r0, 1
addi r9, r0, 1
addi r7, r0, 1
addi r8, r0, 1
addi r9, r0, 1
beqz r0, salto
addi r11, r0, 4
ciao:
addi r7, r0, 1
addi r8, r0, 1
addi r9, r0, 1
addi r7, r0, 1
addi r8, r0, 1
addi r9, r0, 1
jalr r31
addi r9, r0, 3
salto:
addi r7, r0, 1
addi r9, r0, 1
addi r7, r0, 1
jr r31
addi r11, r0, 4
