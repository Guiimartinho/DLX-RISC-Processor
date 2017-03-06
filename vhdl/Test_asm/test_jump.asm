addi r3, r0, 5
addi r2, r0, 10
addi r4, r0, 2
addi r5, r0, 1
addi r6, r0, 3
sw 10(r2), r3	#store MEM[10+R(r2)] <- R(r3) 
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
beqz r0, fine
ciao:
addi r7, r0, 1
addi r8, r0, 1
addi r9, r0, 1
addi r7, r0, 1
addi r8, r0, 1
addi r9, r0, 1
jalr r31
addi r9, r0, 3
fine:
addi r7, r0, 1
addi r8, r0, 1
addi r9, r0, 1
j fine2
addi r7, r0, 1
addi r8, r0, 1
addi r9, r0, 1
addi r7, r0, 1
fine2:
addi r7, r0, 1
addi r8, r0, 1
addi r9, r0, 1
addi r7, r0, 1
jr r31