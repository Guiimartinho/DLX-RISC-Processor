l1: 
add r9,r20,r10 		#0 
addi r1,r2,#-5 		#-5
and r9,r3,r10 		#0
andi r20,r9,#8 		#0
lw r19, 63(r8) 		#0
nop
ori r5, r3, #342	#342
sge r1,r2,r10		#1
sgei r9,r20,#6		#0
sle r13,r2,r4		#1
slei r1,r3,#-4		#0
sll r1,r2,r3		#0
slli r4,r1,#5		#0
sne r1,r2,r3		#0
snei r3,r5,#4		#1
srl r5,r7,r8		#0
srli r7,r5,#2		#0
sub r6,r12,r15		#0
subi r7,r9,#-30		#30
xor r6,r12,r15		#0
xori r6,r12,#1		#1
addu r5,r3,r4		#1
addui r1,r5,#250	#251
lb r1,3-4(r2) 		#nop
lbu r3,5-4(r4)		#nop
lhi r1,#-40			#1111111111011000 & x"0000"
lhu r2,32(r6) 		#nop
mult r5,r2,r4		#0
sb 41(r3), r2		#nop
seq r13,r1,r4		#0
seqi r29,r20,#1		#0
sgeu r9,r20,r10		#1
sgeui r7,r8,#23		#0
sgt r1,r2,r3		#0
sgti r4,r1,#15		#0
sgtu r5,r6,r3		#0
sgtui r15,r3,#8		#0
slt r5,r7,r8		#0
slti r9,r10,#30		#1	
sltu r17,r13,r14	#0
sltui r5,r7,#13		#1
sra r1,r2,r3		#0
srai r25,r26,#10	#0
subu r13,r2,r4		#0
subui r5,r18,#4		#-4
or r5, r3, r4		#1
sleu r13,r2,r9		#1
sleui r22,r30,#30	#1
j l1				# start again