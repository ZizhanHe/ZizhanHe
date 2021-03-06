# Student ID = 260943211
##########################image transpose##################
.data
.text
.globl transpose
##########################image transpose##################
transpose:
	# $a0 -> image struct
	###############return################
	# $v0 -> image struct s.t. contents containing the transpose image.
	# Note that you need to rewrite width, height and max_value information
	
	move $s0,$a0	#s0 has address to input, increment by 4 bytes
	
	lw $s4,($s0)	#s4 has width (new height)
	lw $s5,4($s0)	#s5 has height	(new width)
	
	move $s6,$s5 	#transpose width
	move $s7,$s4	#transpose height
	
	#allocate  4*(w*h+3) bytes
	mult $s4,$s5	#w*h
	mflo $a0	# a0=w*h
	addi $t3,$0,3	
	add $a0,$a0,$t3	#a0=w*h+3
	addi $t3,$0,4
	mult $a0,$t3	# (w*h+3)*4
	mflo $a0	# a0= (w*h+3)*4
	
	addi $sp,$sp,-4
	sw $ra,4($sp)
	
	jal malloc	#output img strut address in v0 increment by 4 bytes
	
	lw $ra,4($sp)
	addi $sp,$sp,4
	
	move $s1,$v0	##s1 has address of output
	
	#write header to s1
	sw $s6,($s1)	#write height as width
	sw $s7,4($s1)	#write width ad height
	lw $t3,8($s0)
	sw $t3,8($s1)	#saves max val
	
	#now header has been writen in s1
	#loop through s0, read content into t2, find x,y using index
	#find x,y for transpose, compute offset by y*width+x, saves t2
	move $t8,$s0	#t8 has img sturct
	addi $t8,$t8,12	#points to content
	
	move $t9,$s1	#t9 has transpose
	addi $t9,$t9,12	#points to content
	
	addi $t0,$0,0	#t0 is index
	
	mult $s4,$s5
	mflo $s2	#s2 is size
	
looptrans: ble $s2,$t0,looptransexit	#exit if index>=size	
	lw $t2,($t8)	#load from image struct
	addi $t8,$t8,4
	
	#calculate x of img struct, x=t0%width
	div $t0,$s4
	mfhi $t4	#t4 has x in img stru
	
	#calculate y, y=t0/width
	div $t0,$s4
	mflo $t5	# t5 has y in img stru
	
	#switch x,y 
	move $t3,$t4	#move x in tmp
	move $t4,$t5	#move y to x
	move $t5,$t3	#move tmp to y
	#t4->x t5->y
	
	#index in transpose= y*width+x
	mult $t5,$s6	#y*width
	mflo $t3	#t3=y*width
	add $t3,$t3,$t4	#t3=y*width+x
	
	addi $t7,$0,4
	mult $t3,$t7	#offset= 4*(y*width+x) bytes
	mflo $t7	#t7 is offset in transpose
	
	add $t7,$t9,$t7	# t7= adress transpose+offset transpose
	sw $t2,($t7)
	
	addi $t0,$t0,1 #increment index
	j looptrans

looptransexit:
	move $v0,$s1
	


transpose.return:
	jr $ra
