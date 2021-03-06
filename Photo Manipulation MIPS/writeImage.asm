# Student ID = 1234567
####################################write Image#####################
.data
str: .asciiz "Error occured opeing the file to write"
#testing: struct: .word 6,5,15,0,0,0,0,0,0,0,0,10,10,15,0,0,14,14,14,14,8,12,3,0,0,0,0,3,6,7,8,9,10
#testing: file: .asciiz "img5.pgm"
.align 2
memoryErrMessage:	.asciiz "Out Of Memory\n"
int2strBuffer:	.word 36
.text
.globl write_image
####################################write Image#####################
write_image:
	# $a0 -> image struct
	# $a1 -> output filename
	# $a2 -> type (0 -> P5, 1->P2)
	################# returns #################
	# void
	#test: la $a0,struct
	#test: la $a1,file
	#test: addi $a2,$0,0
	
	move $s0,$a0 #s0 contains the address of img struct
	#open the file
	addi $sp,$sp,-4
	sw $ra,4($sp)
	li $v0,13 #open file, 
	move $a0,$a1	#put file name into $a0
	addi $a1,$0,1	#flag 1 for write
	syscall
	lw $ra,4($sp)
	addi $sp,$sp,4
	ble $v0,$0,error
	
	move $s1,$v0 #s1 contains file decript
	
	#reads header
	addi $sp,$sp,-4
	sw $ra,4($sp)
	
	move $a0,$s0 #put address of img struct into $a0
	jal readHeader
	
	lw $ra,4($sp)
	addi $sp,$sp,4

	move $a0,$v0 #$a0 contains the number of bytes to allocate
	
	add $s3,$0,$v0	#s3 contains the maximum number of bytes in output
	
	addi $sp,$sp,-4
	sw $ra,4($sp)
	
	jal malloc
	move $s2,$v0 #$s2 has the address of output 
	
	lw $ra,4($sp)
	addi $sp,$sp,4
	###s0-> adrs img struct , s1-> file descript, s2-> adrs of output, s3->int max number char in output
	
	#first determine if its p2 or p5
	beq $a2,0,P5

P2:	
	move $t9,$s2	#t9 will point to the address for saving char,increment by 1bytes per char!
	move $t8,$s0	#t9 will point to the img struct, increment by 4bytes each time!
	
	addi $t1,$0,80 #ascii for P
	sb $t1,($t9)
	addi $t9,$t9,1	#increment pointer
	
	addi $t1,$0,50 #ascii for 2
	sb $t1,($t9)	#writes 'P2' into address
	addi $t9,$t9,1	#increment pointer
	
	addi $t1,$0,10 #new line char
	sb $t1,($t9)	#writes 'P2\n' to address
	addi $t9,$t9,1	#increment pointer
	
	###reads width and write width
	lw $a0,($t8)	#loads int width into $a0 from img struct
	addi $t8,$t8,4	#increment $t8 by 4 bytes to point to next int.
	
	#store variables on stack
	addi $sp,$sp,-8
	sw $ra,8($sp)
	sw $t8,4($sp)
	sw $t9,0($sp)
	jal int2str #v0 has the address to (str) width, v1 has the length of str (with blank space)
	lw $ra,8($sp)
	lw $t8,4($sp)
	lw $t9,0($sp)
	addi $sp,$sp,8
	
	addi $t0,$0,0	#t0 is counter
	#now writes str(width) to output
loop1:	ble $v1,$t0,exit1	#exit if counter>=length. loop if counter<length
	lb $t7,($v0)	#load char from (str) width
	sb $t7,($t9)	#write to output
	addi $t0,$t0,1	#increment counter
	addi $t9,$t9,1	#increment pointer to output
	addi $v0,$v0,1	#increment pointer to (str) width
	j loop1
	
exit1:	#now "P2/n30 ' is written into output. $t9 points to the next empty address

	###reads height and write height
	lw $a0,($t8)	#loads int height into $a0 from img struct
	addi $t8,$t8,4	#increment $t8 by 4 bytes to point to next int.
	addi $sp,$sp,-8
	sw $ra,8($sp)
	sw $t8,4($sp)
	sw $t9,0($sp)
	jal int2str #v0 has the address to (str) height, v1 has the length of str (with blank space)
	lw $ra,8($sp)
	lw $t8,4($sp)
	lw $t9,0($sp)
	addi $sp,$sp,8
	
	addi $t0,$0,0	#t0 is counter
	addi $v1,$v1,-1	#reserve one space for \n
	
	#now writes str to output
loop2:	ble $v1,$t0,exit2	#exit if counter>=length. loop if counter<length
	lb $t7,($v0)	#load char from (str) width
	sb $t7,($t9)	#write to output
	addi $t0,$t0,1	#increment counter
	addi $t9,$t9,1	#increment pointer to output
	addi $v0,$v0,1	#increment pointer to (str) width
	j loop2

exit2: #now "P2/n30 15" is written, add \n 
	addi $t1,$0,10	#new line char
	sb $t1,($t9)	#writes to output
	addi $t9,$t9,1	#increment pointer to output
	
	####P2/n30 14\n" is written, write maxVal
	lw $a0,($t8)	#load int max value
	addi $t8,$t8,4	#increment img struct pointer by a word
	addi $sp,$sp,-8
	sw $ra,8($sp)
	sw $t8,4($sp)
	sw $t9,0($sp)
	jal int2str #v0 has the address to (str) maxval, v1 has the length of str (with blank space)
	lw $ra,8($sp)
	lw $t8,4($sp)
	lw $t9,0($sp)
	addi $sp,$sp,8
	
	addi $t0,$0,0	#t0 is counter
	addi $v1,$v1,-1	#reserve one space for \n
	
	#now writes str to output
loop3:	ble $v1,$t0,exit3	#exit if counter>=length. loop if counter<length
	lb $t7,($v0)	#load char from (str) width
	sb $t7,($t9)	#write to output
	addi $t0,$t0,1	#increment counter
	addi $t9,$t9,1	#increment pointer to output
	addi $v0,$v0,1	#increment pointer to (str) width
	j loop3
exit3: #now "P2/n30 14\n15" is written, add \n 
	addi $t1,$0,10	#new line char
	sb $t1,($t9)	#writes to output
	addi $t9,$t9,1	#increment pointer to output
	

#########write content 
	#outer loop and inner loop
	addi $t5,$0,0 #counter width, inner loop
	addi $t6,$0,0 #counter height, outer loop
	#load width and height
	lw $s5,($s0)	#s5=width
	lw $s6,4($s0)	#s6=height
	
outerloop:	ble $s6,$t6,outerExit	#exit outer loop if counter>=height
innerloop:	ble $s5,$t5,innerExit	#exit inner loop if counter>=width
	#load content, convert to ascii, and save it
	lw $a0,($t8)	#load int content into $a0
	addi $t8,$t8,4	#increment pointer by a word
	
	addi $sp,$sp,-8
	sw $ra,8($sp)
	sw $t8,4($sp)
	sw $t9,0($sp)
	jal int2str	#$v0 will have the pointer to str, $v1 has the length of str
	lw $ra,8($sp)
	lw $t8,4($sp)
	lw $t9,0($sp)
	addi $sp,$sp,8
	
	addi $t0,$0,0	#t0 is counter
	#now writes str to output
loopct:	ble $v1,$t0,exitct	#exit if counter>=length. loop if counter<length
	lb $t7,($v0)	#load char from (str) width
	sb $t7,($t9)	#write to output
	addi $t0,$t0,1	#increment counter
	addi $t9,$t9,1	#increment pointer to output
	addi $v0,$v0,1	#increment pointer to (str) width
	j loopct
exitct:	#now the content has be written
	addi $t5,$t5,1 	#increment counter
	j innerloop	

innerExit:#now a row has been written
	addi $t6,$t6,1	#increment height pointer
	
	#add a \n to output
	addi $t0,$0,10	#new line char in $t0
	sb $t0,($t9)	#saves new line char into output
	addi $t9,$t9,1
	addi $t5,$0,0 #reset counter width, inner loop
	j outerloop
	
outerExit:	#all content are written
	j endprog
	

	
P5:	
	move $t9,$s2	#t9 will point to the address for saving char,increment by 1bytes per int!
	move $t8,$s0	#t9 will point to the img struct, increment by 4bytes each time!
	
	addi $t1,$0,80 #ascii for P
	sb $t1,($t9)
	addi $t9,$t9,1	#increment pointer
	
	addi $t1,$0,53 #ascii for 5
	sb $t1,($t9)	#writes 'P5' into address
	addi $t9,$t9,1	#increment pointer
	
	addi $t1,$0,10 #new line char
	sb $t1,($t9)	#writes 'P5\n' to address
	addi $t9,$t9,1	#increment pointer
	
	###reads width and write width
	lw $a0,($t8)	#loads int width into $a0 from img struct
	addi $t8,$t8,4	#increment $t8 by 4 bytes to point to next int.
	
	#store variables on stack
	addi $sp,$sp,-8
	sw $ra,8($sp)
	sw $t8,4($sp)
	sw $t9,0($sp)
	jal int2str #v0 has the address to (str) width, v1 has the length of str (with blank space)
	lw $ra,8($sp)
	lw $t8,4($sp)
	lw $t9,0($sp)
	addi $sp,$sp,8
	
	addi $t0,$0,0	#t0 is counter
	#now writes str(width) to output
loop15:	ble $v1,$t0,exit15	#exit if counter>=length. loop if counter<length
	lb $t7,($v0)	#load char from (str) width
	sb $t7,($t9)	#write to output
	addi $t0,$t0,1	#increment counter
	addi $t9,$t9,1	#increment pointer to output
	addi $v0,$v0,1	#increment pointer to (str) width
	j loop15
	
exit15:	#now "P5/n30 ' is written into output. $t9 points to the next empty address

	###reads height and write height
	lw $a0,($t8)	#loads int height into $a0 from img struct
	addi $t8,$t8,4	#increment $t8 by 4 bytes to point to next int.
	addi $sp,$sp,-8
	sw $ra,8($sp)
	sw $t8,4($sp)
	sw $t9,0($sp)
	jal int2str #v0 has the address to (str) height, v1 has the length of str (with blank space)
	lw $ra,8($sp)
	lw $t8,4($sp)
	lw $t9,0($sp)
	addi $sp,$sp,8
	
	addi $t0,$0,0	#t0 is counter
	addi $v1,$v1,-1	#reserve one space for \n
	
	#now writes str to output
loop25:	ble $v1,$t0,exit25	#exit if counter>=length. loop if counter<length
	lb $t7,($v0)	#load char from (str) width
	sb $t7,($t9)	#write to output
	addi $t0,$t0,1	#increment counter
	addi $t9,$t9,1	#increment pointer to output
	addi $v0,$v0,1	#increment pointer to (str) width
	j loop25

exit25: #now "P5/n30 15" is written, add \n 
	addi $t1,$0,10	#new line char
	sb $t1,($t9)	#writes to output
	addi $t9,$t9,1	#increment pointer to output
	
	####P5/n30 15\n" is written, write maxVal
	lw $a0,($t8)	#load int max value
	addi $t8,$t8,4	#increment img struct pointer by a word
	addi $sp,$sp,-8
	sw $ra,8($sp)
	sw $t8,4($sp)
	sw $t9,0($sp)
	jal int2str #v0 has the address to (str) maxval, v1 has the length of str (with blank space)
	lw $ra,8($sp)
	lw $t8,4($sp)
	lw $t9,0($sp)
	addi $sp,$sp,8
	
	addi $t0,$0,0	#t0 is counter
	addi $v1,$v1,-1	#reserve one space for \n
	
	#now writes str to output
loop35:	ble $v1,$t0,exit35	#exit if counter>=length. loop if counter<length
	lb $t7,($v0)	#load char from (str) width
	sb $t7,($t9)	#write to output
	addi $t0,$t0,1	#increment counter
	addi $t9,$t9,1	#increment pointer to output
	addi $v0,$v0,1	#increment pointer to (str) width
	j loop35
exit35: #now "P5/n30 14\n15" is written, add \n 
	addi $t1,$0,10	#new line char
	sb $t1,($t9)	#writes to output
	addi $t9,$t9,1	#increment pointer to output
	

#########write content 
	#outer loop and inner loop
	addi $t5,$0,0 #counter width, inner loop
	addi $t6,$0,0 #counter height, outer loop
	#load width and height
	lw $s5,($s0)	#s5=width
	lw $s6,4($s0)	#s6=height
	
outerloop5:	ble $s6,$t6,outerExit5	#exit outer loop if counter>=height
innerloop5:	ble $s5,$t5,innerExit5	#exit inner loop if counter>=width
	#load content, don't convert to ascii! and save it as byte
	lw $a0,($t8)	#load int content into $a0
	addi $t8,$t8,4	#increment pointer by a word
	sb $a0,($t9)	#save to output
	addi $t9,$t9,1	#increment pointer to output by ONE byte! 
	addi $t5,$t5,1 	#increment counter
	j innerloop5

innerExit5:#now a row has been written
	addi $t6,$t6,1	#increment height pointer
	addi $t5,$0,0 #reset counter width, inner loop
	j outerloop5
	
outerExit5:	#all content are written
	j endprog
	
	
	
readHeader:
	#a0-> address of img struct
	#####returns####
	#$v0 number of bytes to allocate based on width and height.
	lw $t1,($a0)	#$t1 has width
	lw $t2,4($a0)	#$t2 has the height
	#calculate the number of bytes to allocate
	add $t3,$t1,$t1 #t3=2*width
	mult $t3,$t2 #t3=2*width*height
	mflo $t3
	addi $t4,$0,3
	mult $t3,$t4 #allocate t3=3*(2*width*heigh) byte
	mflo $t3
	#allocate this much because size of content =w*h, with spaces in between ascii, this would be 2*w*h.
	#each index could have up to 3 digits max value (256), so allocate 3* more
	move $v0,$t3
	jr $ra



	
error: li $v0,4
	la $a0,str
	syscall
	j exitProg
	
endprog:#all contents are written
	#write to file 
	addi $sp,$sp,-4
	sw $ra,4($sp)
	li $v0,15	#for write file
	move $a0,$s1	#$a0 has file descript
	move $a1,$s2	#$a1 has the address of output
	move $a2,$s3	#$a2 has max number of bytes to output
	syscall
	lw $ra,4($sp)
	addi $sp,$sp,4
	j exitProg
	
exitProg: 
write_image.return:
	jr $ra

