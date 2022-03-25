# Student ID = 260943211
###############################str2int######################
.data
str:		.asciiz "1281"
.align 2
blank:		.asciiz "\n"
.text
.globl str2int	
###############################str2int######################

#testing
#main:	la $a0,str
	#jal str2int
	#add $a0,$0,$v0
	
	#li $v0,1
	#syscall
	#j programend
	

str2int:
	# $a0 -> address of string, i.e "32", terminated with 0, EOS
	###### returns ########
	# $v0 -> return converted integer value
	# $v1 -> length of integer
	###########################################################
	
	#loop through the string, find its length
	addi $v1,$zero,0 #$vo will contain the length
	add $t9,$0,$a0	#$t9 has the address of str, whill change

looplength:lb $t1,($t9)

	addi $t8,$0,32	#ascii for space
	bne $t1,$t8,next
	j end

next:	addi $t9,$t9,1	#increment $t9 by 1 byte
	addi $v1,$v1,1	#increment length
	j looplength

#$v1 now contiains the length of str
end:	addi $t2,$v1,-1	#$t2 is the offset/counter
	addi $t3,$0,1	#$t3 is the multiple of 10 starting from 10^0
	addi $v0,$0,0	#v0 will have the int result of str
	addi $t4,$0,0	#will hold the str val of a byte
	addi $t5,$0,0	#$t5 will hold tmp address
	
#loop from end to start of str, and add each byte multiplied by pow of 10 to result.
#eg. '123'=3*10^0 + 2*10^1 + 3*10^2
loopint: blt $t2,$0,exit	#exit if offset <0
	add $t5,$a0,$t2		#address to load=initial address+offset
	lb $t4,($t5)		#$t4 will have char at initial address+offset
	addi $t7,$t4,-48	#convert char to decimal, put into $t7
	mult $t3,$t7		#mult $t7 digit by pow of 10
	mflo $t6	#$t6 will contain the resrult of pow of 10 * digit. Since we only consider 3 digit int, won't exceed lo.
	add $v0,$v0,$t6
	#Increment
	addi $t2,$t2,-1
	addi $t6,$0,10
	mult $t3,$t6
	mflo $t3
	j loopint

exit: j str2int.return
	
str2int.return:
	jr $ra

#programend:
	
