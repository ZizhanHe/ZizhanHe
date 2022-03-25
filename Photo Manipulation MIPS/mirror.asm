# Student ID = 260943211
########################## mirror #######################
.data
.text
.globl mirror_horizontally
########################## mirror #######################
mirror_horizontally:
	# $a0 -> image struct
	###############return################
	# $v0 -> image struct s.t. mirrored image horizontally. 
	
	
	#inner loop . current address is starting address, current adrs + (width-1)*4 is ending adrs
	#loop through the row in image struct, increment img struct start pointer and decrement end pointer in output
	
	#outer loop, loop through rows of img struct, at each loop, increment img struct adrs and output adrs by a row (width*4)
	
	#first contruct a new img struct with the same header
	
	move $s0,$a0	###########s0 has address to input, increment by 4 bytes
	
	lw $s4,($s0)	#s4 has width (new height)
	lw $s5,4($s0)	#s5 has height	(new width)
	
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
	
	move $s1,$v0	#################s1 has address of output
	
	#write header
	sw $s4,($s1)
	sw $s5,4($s1)
	lw $t3,8($s0)
	sw $t3,8($s1)
	
	#header is written
	
	#s2 be the offest incremented at outer loop (width *4)
	addi $t3,$0,4
	mult $s4,$t3
	mflo $s2
	
	#s3 be the offset to get end index at inner loop (wid-1)*4
	add $t2,$s4,-1	#wid-1
	addi $t3,$0,4
	mult $t2,$t3
	mflo $s3	#s3=(wid-1)*4
	
	addi $t2,$0,0	#row couter from (0-height-1)inclusive
	
	move $t8,$s0	#t8 has address of img struct
	move $t9,$s1	#t9 has address of output
	
	addi $t8,$t8,12	#point to content
	addi $t9,$t9,12
	
outer:	ble $s5,$t2,outerexit	#exit if row counter>=height
	addi $t1,$0,0	#inner/col counter, from (0-width-1) inclusive
	#t8,t9 points to start of the row
	move $t4,$t8	#t4 has tmp adrs to img struct,loop left to right. Increment by 4 bytes!
	move $t5,$t9	#t5 has tmo adrs to output, start of the row, loop right to left.
	
	add $t5,$t5,$s3	#t5 points to the end of row in output. Decrement by 4 Bytes!
	
inner:	ble $s4,$t1,innerexit
	addi $t1,$t1,1	#increment col counter
	
	lw $t3,($t4)	#load from img struct
	addi $t4,$t4,4
	sw $t3,($t5)
	addi $t5,$t5,-4
	j inner

innerexit:
	addi $t2,$t2,1	#increment row counter
	add $t8,$t8,$s2 #increment t8 to point to next row in img struct
	add $t9,$t9,$s2	#increment t9 to point to next row in output
	j outer
outerexit:	#now all img struct has flipped.
	move $v0,$s1

mirror_horizontally.return:
	jr $ra

