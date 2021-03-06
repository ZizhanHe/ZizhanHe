# Student ID = 260943211
#########################Read Image#########################
.data
#for testing: file: 	.asciiz	"feepP2.pgm"
errormsg:	.asciiz "error occured opening the file"
tmpbuffer:	.space 4		#used to store 3digit ascii eg. '125'
readbuffer: .space 1
intbuffer:	.word 4		#used to store (int) Width,Height,Maxval
space: .asciiz " "

.text
.globl read_image
#########################Read Image#########################
read_image:
	# $a0 -> input file name, it will be either P2 or P5 file
        # You need to check the char after 'P' to determine the image type. 
	################# return #####################
	# $v0 -> Image struct :
	# struct image {
	#	int width;
	#       int height;
	#	int max_value;
	#	char contents[width*height];
	#	}
	##############################################
	# Add code here
	
	#For P2 you need to use str2int 
	#for testing :la $a0,file
	
	#open file
	li $v0,13
	addi $a1,$0,0	#flag=0 for read
	syscall 
	
	ble $v0,$0,error	#exit if v0<0
	move $s0,$v0	#####s0 contains file desctript
	
	#read 3 bytes 'P2\n' or 'P5\n'
	li $v0,14
	move $a0,$s0
	la $a1,tmpbuffer
	addi $a2,$0,3	#read 2 byte
	syscall
	#tmpbuffer should have 'P2\n' or 'P5\n'
	
	la $t0,tmpbuffer
	lb $t2,1($t0)	#t2 should be '2' or '5'
	move $s7,$t2

	#loop through header, and read Width,Height,Maxval
	# stop when reaches 3rd \n
	#for each ascii, if not space or \n, save to tmpbuffer, which will be used to convert to int
	#convert tmpbuffer to int, store int in intbuffer.
	#at the end, intbuffer will hold Width,Height,Maxval in int.

	 addi $t6,$0,3 #t6 represent 3 infos should be read
	 la $t0,readbuffer	#1 byte buffer for read file
	 la $a1,tmpbuffer	#a1 has the address of tmpbuffer, where its used to store '256 ' to be covnerted to int
	 la $a2,intbuffer	#$a2 points to he address where int data are stored
	 
outerloop: ble $t6,$0,outerexit	#exit if t6<=0, which we've read all infos
	move $t5,$a1	#t5 has address to tmpbuffer for ascii
innerloop:	
	#get the char
	addi $sp,$sp,-4
	sw $a1,4($sp)
	sw $a2,0($sp)
	li $v0,14
	move $a0,$s0
	la $a1,readbuffer
	addi $a2,$0,1	#reads one byte into readbuffer
	syscall
	lw $a1,4($sp)
	lw $a2,0($sp)
	addi $sp,$sp,4
	
	lb $t1,($t0)	#load char into $t1
	
	#read data if t1 is not Space or \n
	addi $t3,$0,32	#$t3 has ascii for space
	beq $t1,$t3,innerexit
	add $t3,$0,10	#t3 has ascii for \n
	beq $t1,$t3,innerexit
	#read data
	sb $t1,($t5)
	addi $t5,$t5,1	#increment pointer
	j innerloop
innerexit:	#tmpbuffer has ascii int eg.'123'
	addi $t3,$0,32	#ascii for space
	sb $t3,($t5)	#writes a space at the end
	#now convert ascii to int
	
	addi $sp,$sp,-16
	sw $ra,16($sp)
	sw $t0,12($sp)
	sw $t6,8($sp)
	sw $a1,4($sp)
	sw $a2,0($sp)
	move $a0,$a1	#move address of tmpbuffer into a0
	jal str2int	#v0 has the int val, v1 has int length
	lw $ra,16($sp)
	lw $t0,12($sp)
	lw $t6,8($sp)
	lw $a1,4($sp)
	lw $a2,0($sp)
	addi $sp,$sp,16
	
	sw $v0,($a2)	#saves int val into intbufffer
	addi $a2,$a2,4	#increment pointer to intbuffer by a word
	addi $t6,$t6,-1	#decrement counter
	j outerloop

outerexit:#now intbuffer has width,height,maxvalue
	#t2 contains '2' or '5'
	la $t6,intbuffer
	lw $t3,($t6)	#t3 has width
	lw $t4,4($t6)	#t4 has height
	move $s4,$t3	####s4 has width
	move $s5,$t4    ####s5 has height
	lw $s6,8($t6)	###s6 has max val
	
	mult $t3,$t4	#width * height
	mflo $t3	#t3=wid*height
	addi $t3,$t3,3	#t3=width*height+3
	move $s1,$t3	# s1 has num of integers in output
	addi $t0,$0,4
	mult $t3,$t0	#	(width*height+3)*4
	mflo	$a0
	addi $sp,$sp,-4
	sw $ra,4($sp)
	jal malloc
	lw $ra,4($sp)
	addi $sp,$sp,4
	move $s2,$v0	### s2 has the address to img struct output buffer.
	#s0 has file descript

	move $t9,$s2
	#t9 points to int img struct output, increment by 4bytes!

	##write w,h,m into output
	#s4 s5 s6 has width,heigh,maxval
	sw $s4,($t9)	#save width to output
	addi $t9,$t9,4
	sw $s5,($t9)	#save height into output
	addi $t9,$t9,4
	sw $s6,($t9)	#save max val into output
	addi $t9,$t9,4	#increment pointer to output by 4 byte
	#output has 30,14,15

	addi $t3,$0,53	#ascii for 5
	beq $s7,$t3,P5
	
	#The next read file syscall will read the content.

P2:
	
	
	#should exactly reads # width*height 
	mult $s4,$s5
	mflo $t1	#t1 is the total number of pixel to read
	add $t0,$0,0	#t0 is num of pixel that has been read
	la $a3,tmpbuffer #a3 has the address to tmpbuffer used to store ascii num '123 ' 
	la $t8,readbuffer #t8 has the address to readbuffer used to store 1 byte
	addi $t7,$0,0	# t7 is \n counter, if t7>height, then we've read all conten
	#use $s7 to store previous value
	#addi $s7,$0,32	#ascii for space

outerloopct: ble $t1,$t0,outerexitct #exit if $t0 >= $t1
	move $t6,$a3	##t6 has the address of tmpbuffer
innerloopct: 
	li $v0,14
	move $a0,$s0
	move $a1,$t8
	addi $a2,$0,1
	syscall		#reads a byte and store it in readbuffer
	
	lb $t3,($t8)	#load ascii from img into t3
	addi $t5,$0,32 	#ascii for space
	beq $t3,$t5,innerexitct	#exit if ascii is blank space, this means we've store the entire num into tmpbuffer, and we can add ' ' and conevrt to int.
	#move $s7,$t3
	addi $t5,$0,10
	beq $t3,$t5,newrowPending #if its \n, then it means we've finished one row, move to next one.
	beq $t3,$0,outerexitct	#also exit if reaches the end EOF.
	
	sb $t3,($t6)	#if not a space, store ascii into tmpbuffer
	addi $t6,$t6,1	#increment pointer to tmpbuffer
	j innerloopct

#pending:addi $t5,$0,32
	#beq $s7,$t5,outerloopct #if last char is also space, move on to next loop
	#move $s7,$t3
	#j innerexitct
newrowPending:addi $t7,$t7,1
	blt $s5,$t7,outerexitct
	j outerloopct


innerexitct:
	#saves a space at the end
	addi $t5,$0,32 #ascii for space
	sb $t5,($t6)	#save space into tmpbuffer
	
	lb $t5,($a3)	#loads ascii from the first byte in tmpbuffer. if $t5==space, then jump to next loop
	addi $t6,$0,32	#ascii for space
	beq $t5,$t6,outerloopct
	
	#now convert ascii to str
	addi $sp,$sp,-24
	sw $t0,0($sp)
	sw $t1,4($sp)
	sw $a3,8($sp)
	sw $t8,12($sp)
	sw $t9,16($sp)
	sw $t7,20($sp)
	sw $ra,24($sp)
	move $a0,$a3
	jal str2int
	lw $t0,0($sp)
	lw $t1,4($sp)
	lw $a3,8($sp)
	lw $t8,12($sp)
	lw $t9,16($sp)
	lw $t7,20($sp)
	lw $ra,24($sp)
	addi $sp,$sp,24
	#$v0 has int value, store v0 into output
	sw $v0,($t9)	#save int to output
	addi $t9,$t9,4	#increment pointer by 4 bytes
	addi $t0,$t0,1	#increment read pixel by 1
	j outerloopct

outerexitct: #now all content has been written into img struct pointed by $s2.
	j endprog

P5:
	#should exactly reads # width*height 
	mult $s4,$s5
	mflo $t1	#t1 is the total number of pixel to read
	add $t0,$0,0	#t0 is num of pixel that has been read
	la $t8,readbuffer #t8 has the address to readbuffer used to store 1 byte

loopctp5: ble $t1,$t0,exitctp5 #exit if $t0 >= $t1
	li $v0,14
	move $a0,$s0
	move $a1,$t8
	addi $a2,$0,1
	syscall		#reads 1 byte int and store it in readbuffer
	
	lb $t3,($t8)	#load 1 byet int into $t3
	
	sw $t3,($t9)	#save int to output
	addi $t9,$t9,4	#increment pointer by 4 bytes
	addi $t0,$t0,1	#increment read pixel by 1
	j loopctp5

exitctp5: #now all content has been written into img struct pointed by $s2.
	j endprog


error:
	li $v0,4
	la $a0,errormsg
	syscall
	j read_image.return

endprog: move $s7,$s2
	#print img struct
	#addi $t1,$0,0
#printloop: ble $s1,$t1,printend
	#li $v0,1
	#lw $a0,($s2)
	#syscall
	#addi $s2,$s2,4
	#addi $t1,$t1,1
	
	#li $v0,4
	#la $a0,space
	#syscall
	
	#j printloop
#printend:
	#prints new line
	#li $v0,11
	#addi $a0,$0,10
	#syscall


	#return

read_image.return:
	move $v0,$s7
	jr $ra
