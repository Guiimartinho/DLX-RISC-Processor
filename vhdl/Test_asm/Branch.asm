addi r1, r0, 100	#100
xor r2, r2, r2		#0

ciclo:
subi r1, r1, 1		# index, at each iteration -1
lw r3, 0(r2)		# load R(r3) <- MEM[0+R(r2)]. It will find something different from 0 only after 25 iteration
addi r3, r3, 10		
sw 100(r2), r3		# store MEM[100+R(r2)] <- R(r3) 
addi r2, r2, 4	   
bnez r1, ciclo	    # salta per 100 iterazioni 
addi r4, r0, 65535  #Branch Delay Slot # equals to "-1" since is sign extended. It is reapeated at each iteration but who cares since the result is always the same and r4 is not used
ori r5, r4, 100000  # 100000 non ci sta su 16 bit, e quindi usa 34464 
add r6, r4, r5		

end:
j end				# loop in the end