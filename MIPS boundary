# Student ID = 260943211
###############################image boundary######################
.data
.text
.globl image_boundary
##########################image boundary##################
image_boundary:
	# $a0 -> image struct
	############return###########
	# $v0 -> image struct s.t. contents containing only binary values 0,1

	#create a copy of img struct with only header written, and body all 0s
	# whm[content]
	move $s0,$a0	#s0 has address to input, increment by 4 bytes
	
	lw $s4,($s0)	#s4 has width
	lw $s5,4($s0)	#s5 has height
	
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
	
	#now write header into s1
	sw $s4,($s1)	#saves width
	sw $s5,4($s1)	#saves height
	lw $t3,8($s0)	#loads max val
	sw $t3,8($s1)	#saves max val
	
	#loop through s1 and put 0s
	mult $s4,$s5	#width*height
	mflo $t9	#t9 = total number of pixels
	addi $t1,$0,0	#counter
	
	move $t8,$s1	#t8 has address of output
	addi $t8,$t8,12 #move t8 to point to content

loopfill: ble $t9,$t1,loopfillexit	#exit if counter==t9, counter 0-(totol pixel-1) inclusive
	sw $0,($t8)
	addi $t8,$t8,4
	addi $t1,$t1,1

loopfillexit:	#now the output is filled with 0s

#loop through s0, get pixel. if pixel!=0, then get upper, left....(if they exists)

	
	
	addi $t0,$0,0	#t0 is index
	
	mult $s4,$s5
	mflo $s6	# s6=size
	
	move $t8,$s0	#t8 has address to img struct input
	addi $t8,$t8,12 #t8 points to content
	
	move $t9,$s1	#t9 has address to output
	add $t9,$t9,12	
	
	
	#loop through img struct, if pixel is not 0, check left
	#upper, right lower!

loopct: ble $s6,$t0,loopctexit 	#exit if index==size
        #loads from s0, if 0, then next
        lw $t2,($t8)	#load pixel from img struct
        beq $t2,$0,next	#if pixel==0, next
        
        #when pixel not 0, check left, upper, right lower
        
        
 left:
     	#check if left exists
     	div $t0,$s4	#if index%width ==0, then no left
     	mfhi $t3	#t3=index%width
     	
     	beq $t3,$0,upper	#j to check upper if left dones not exists
     	
     	#now left exists. Check if left is 0
     	lw $t2,-4($t8)	#load left into t2
     	bne $t2,$0,upper	#if left is not 0, check upper
     	#left is 0! Mark this pixel in t9 as boundary
     	addi $t3,$0,1
     	sw $t3,($t9)	#save 1 into this address
     	j next
    
    #next increments index, t8,t9

upper: #first check if upper exists
	#upper exists if index-width>=0
	sub $t3,$t0,$s4	#t3=index-width
	blt $t3,$0,right	#check right if upper dont exists
        
        #upper exists, load upper
        move $t7,$t8	#t7 has tmp address of img struct 
        
        addi $t3,$0,4
        mult $s4,$t3	#width *4 bytes
        mflo $t3	#t3= width*4 
        
        sub $t7,$t7,$t3	#address= current- width*4
        lw $t2,($t7)
        
        bne $t2,$0,right
        
        #now upper is 0! Mark this pixel as boundary
        addi $t3,$0,1	
        sw $t3,($t9)
        j next

right:	#check if right exists
	#right dont exists if (index+1)%width==0
	
	move $t4,$t0	#t4 is tmp index
	addi $t4,$t4,1	# index+1
	
	div $t4,$s4	# (index+1)%width
	mfhi $t3	# t3 = (index+1)%width
	
	beq $t3,$0,lower #j to lower if right dont exists
	
	#now #right exists
	lw $t2,4($t8)	#right in t2
	bne $t2,$0,lower	#b to lower if right!=0
	#right is 0, put 1 in this pixel
	addi $t3,$0,1
	sw $t3,($t9)
	j next

lower:	#lower exists if index+width <size
	move $t4,$t0	#t4 is tmp index
	add $t4,$t4,$s4	#t4=index+width
	
	ble $s6,$t4,next #b to next if index+width>=size
	#lower exists, check if its 0
	
	addi $t3,$0,4
	mult $s4,$t3	#width *4 byte
	mflo $t3	# t3=width*4
	
	move $t7,$t8	#t7 is tmp addres of img struct
	add $t7,$t7,$t3 #t7  current adrs+width*4
	
	lw $t2,($t7)
	bne $t2,$0,next
	#lower is 0! saves 1 at this index
	addi $t3,$0,1
	sw $t3,($t9)
	j next       


next: addi $t0,$t0,1	#increment index
	addi $t8,$t8,4	#Increment both address
	addi $t9,$t9,4
	j loopct

loopctexit: #now t9 is written with boundary pixel
	move $v0,$s1

image_boundary.return:
	jr $ra
