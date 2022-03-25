# Student ID = 260943211
###############################int2str######################
.data
.align 2
int2strBuffer:	.word 36
.text
.globl int2str
###############################int2str######################
int2str:
	# $a0 <- integer to convert, only accepts numbers upto 3 digits
	##############return#########
	# $v0 <- space terminated string 
	# $v1 <- length or number string + 1(for space)
	###############################
	
	#addi $a0,$0,999 test
	
	#determine whether the input is 3digit, 2digit, or 1digit
	addi $t0,$0,99
	blt $t0,$a0,threeDigit
	addi $t0,$0,9
	blt $t0,$a0,twoDigit
	addi $t1,$0,1	#$t1 will be used to extract digits
	addi $v1,$0,2	#$ao is 1digit, so length is 2
	j next
threeDigit: addi $t1,$0,100	
	addi $v1,$0,4	#$ao is 3digit, so length is 4
	j next
twoDigit: addi $t1,$0,10
	addi $v1,$0,3	#$ao is 2digit, so length is 3
next:	la $t9,int2strBuffer	#$t9 points to the address where digits are saved

loop:	slt $t8,$0,$t1	#$t1>0?
	beq $0,$t8,end	#exit if $t1<=0
	
	#extract digit
	divu $a0,$t1	#eg. for 3digit,$a0=123, $t1=100, $t2=123/100=1,  $t2 will have the first digit
	mflo $t2 #$t2 will have the digit
	mfhi $a0	#eg. $a0=123, then $t1=100, $t2=first digit=$a0/$t1=1.
			#$a0=123%100=23 will be used for next loop.
	addi $t0,$0,10
	divu $t1,$t1,$t0 #decrement $t1=$t1/10
		
	addi $t3,$t2,48	#$t3 will have the ascii of $t2
	sb $t3,($t9)
	addi $t9,$t9,1	#increment pointer
	j loop

end:	addi $t3,$0,32 #$t3 will hold a space
	sb $t3,($t9)	#adds a space at the end
	#stores the address of int2strBuffer into $v0
	la $v0,int2strBuffer
	j int2str.return
	

int2str.return:
	#add $a0,$0,$v0 test
	#li $v0,4 test
	#syscall test
	jr $ra