# Student ID = 260943211
###############################connected components######################
.data
lowest: .word 11	#stores the lowest vals in 11 pieces.
space: .asciiz " "
.text
.globl connected_components
########################## connected components ##################
connected_components:
	move $s3,$ra
	
	# $a0 -> image struct. Consturcts of all integers. Scan by 4 bytes
	#	 whm[content]
	############return###########
	# $v0 -> image struct with labelled connected components
	# $v1 -> number of connected components (equivalent to number of unique labels)
	
	#@conventions
	# *labels always >= 1 (int)
	# *assume there's only up to 10 equivalent classes, each contains at most 25 distince labels
	#this means 25*10*4 bytes (250 slots) have to be allocated to store equivalent classes
	#* Equivalence classes are stored in an array (allocated by malloc)that is
	#initialized to all 0s. Then the arrray is equally cut into 10 pieces, each pieces
	#has 25 slots to store equivalen labels.
	#-Each piece is separated by a '-1' (negative int)
	
	#labels are no. 0-9
	#each label has 24 slots 
	#total has 250 slots for all 10 pieces
	move $s1,$a0	#####s1 has address to img struct
	
	
	#when storing 2 equivalen label i,j into the array, first check i.
	#loop through equivalence array:
	#	a) i already exists in array
	#		check j:
	#		1) j also exists. -> Dont need to do anything
	#		2) j dont exists. -> add j into i's pieces
	#	b) i does not exist in array
	#		check j:
	#		1) j exists. -> add i to j's pices
	#		2) j dont exists. -> add BOTH i,j to new pieces
	
	#	 write subroutine 
	#	1) inArray (a0-> label, check if label exists in equivalence aray, if
	#exists v0->1, v1-> #of piece its in. if not in, v0->0)
	#	2) addToPiece (a0->label, a1->piece no. Add label to the piece. Find the
	#first avaliable slot in that piece, and add it)
	
	#main
	
	#first allocate space for equivalence array
	addi $a0,$0,1100	#allocate 25*11*4 bytes  (0-10)
	jal malloc
	move $s0,$v0	#####s0 contains the address to equivalence array
	
	#initalized array with each 24 slots separated by a -1
	addi $t9,$0,10	#t9=10, outter upper
	addi $t1,$0,0	# t1 is the piece no. starting from 0, up to 10
	addi $t8,$0,23	#innerupper
	move $t5,$s0 #t5 has tmp addrees of array
	
outerinitial: blt $t9,$t1,outerinitialexit	#exit if 10<t1
	addi $t2,$0,0	#inner counter. From 0-23 inclusive. 24 is for -1
innerinitial: blt $t8,$t2,innerinitialexit	#inner exit if inner counter>23
	sw $0,($t5)
	addi $t5,$t5,4
	addi $t2,$t2,1
	j innerinitial

innerinitialexit:
	addi $t3,$0,-1
	sw $t3,($t5)
	addi $t5,$t5,4
	addi $t1,$t1,1
	j outerinitial

outerinitialexit:	#now that the equivalen array has been intialzed. (in s0)

#print equivalence array for testing


	
	






#first pass
	addi $s2,$0,1	#s2 is labels starting at 1
	
	lw $s4,($s1)	#s4 has width
	lw $s5,4($s1)	#s5 has height
	
	mult $s4,$s5
	mflo $s7	#s7 has total number of pixel
	
	addi $t7,$0,0	#t7 the index of current pixel
	
	move $t8,$s1 #t8 has tmp address to image struct
	addi $t8,$t8,12	#increment address by 3*4 bytes to point to content

#t5 will be upper, t6 will be left
looppass1:
	ble $s7,$t7,looppass1exit
	lw $t2,($t8)	#load pixel from img struct address
	beq $t2,$0,next1	#if piexel==0, then next 
	#if not 0, get label top, label left
	
	#get label top, first check if label top exists
	#ie check if index-width>=0
	sub $t3,$t7,$s4
	blt $t3,$0,noupper	#if t7-s4<0, then set upper label to be 0
	#now upper exists, obtain upper
	move $a0,$t8
	move $a1,$s4
	addi $sp,$sp,-8
	sw $t8,0($sp)
	sw $t7,4($sp)
	sw $ra,8($sp)
	jal gettop
	lw $t8,0($sp)
	lw $t7,4($sp)
	lw $ra,8($sp)
	addi $sp,$sp,8
	move $t5,$v0	#t5 will have val of upper label
	j findleft
	
noupper: addi $t5,$0,0	#t5 upper is set to 0 if no upper exists

findleft:#upper is stored in t5, now find left
	#first check if left exists. ie index%width != 0
	div $t7,$s4
	mfhi $t3
	beq $t3,$0,noleft	#no left if index%width ==0, pixel is on the leftmost col
	#has left, now get left
	move $a0,$t8 #move addres into a0
	addi $a0,$a0,-4
	lw $t6,($a0)	#now t6 is left label
	j determine
	
noleft: addi $t6,$0,0	#label left t6 is set to 0

determine: #now that both t5 upper, t6 left is found,
	#determine label for this pixel
	beq $t5,$0,upperzero	#if t5!=0, check if t6=0
	#t5 not 0, check t6					#when t5 !=0
	beq $t6,$0,oneZero	# when t5 !=0, t6=0
	#now both $t5,$t6 !=0
	j bothValid

upperzero:#when t5==0
	beq $t6,$0,bothZero	#when t5=t6=0
	#when $t5=0,t6!=0
	j oneZero

###
bothZero: 
	sw $s2,($t8)	#saves a new label in this pixel
	
	#add this label to equivalent array
	addi $sp,$sp,-8
	sw $t7,0($sp)
	sw $t8,4($sp)
	sw $ra,8($sp)
	move $a0,$s0	#move address of array in a0
	jal findAvailable #v0 is the available piece
	lw $t7,0($sp)
	lw $t8,4($sp)
	lw $ra,8($sp)
	addi $sp,$sp,8
	
	move $a1,$v0	#piece
	move $a0,$s2	#label
	move $a2,$s0	#address
	addi $sp,$sp,-8
	sw $t7,0($sp)
	sw $t8,4($sp)
	sw $ra,8($sp)
	jal addToPiece #v0=1 if added
	lw $t7,0($sp)
	lw $t8,4($sp)
	lw $ra,8($sp)
	addi $sp,$sp,8
	
	
	addi $s2,$s2,1	#increment label
	addi $t8,$t8,4
	j labelAdded


###
oneZero:
	blt $t5,$t6,leftbigger	#if upper<left. set pixel to be left
	#upper>left
	sw $t5,($t8)	#save upper label into pixel
	j oneZeroend
leftbigger:
	sw $t6,($t8)	#save left into pixel
oneZeroend:
	addi $t8,$t8,4	#Increment address pointer
	j labelAdded


###
bothValid:
	#both t5 t6 will be in array to begin with.
	#move t6 to t5. Delete t6
	
	#if t5==t6, then don't need to do anything. They refer to the same label
	beq $t5,$t6,equiAdded 
	
	#find t6
	move $a0,$t6	#move label to $a0
	move $a1,$s0	#move address in a1
	addi $sp,$sp,-16
	sw $t5,0($sp)
	sw $t6,4($sp)
	sw $t7,8($sp)
	sw $t8,12($sp)
	sw $ra,16($sp)
	jal inArray	#v1 is the piece t6 is in
	lw $t5,0($sp)
	lw $t6,4($sp)
	lw $t7,8($sp)
	lw $t8,12($sp)
	lw $ra,16($sp)
	addi $sp,$sp,16
	
	
	move $a0,$t6	#move label
	move $a1,$v1	#move piece
	move $a2,$s0	#move address
	addi $sp,$sp,-16
	sw $t5,0($sp)
	sw $t6,4($sp)
	sw $t7,8($sp)
	sw $t8,12($sp)
	sw $ra,16($sp)
	jal deleteLabel
	lw $t5,0($sp)
	lw $t6,4($sp)
	lw $t7,8($sp)
	lw $t8,12($sp)
	lw $ra,16($sp)
	addi $sp,$sp,16
	
	#t6 is now deleted
	#add t6 in t5
	#find t5
	move $a0,$t5	#move t5 label to $a0
	move $a1,$s0	#move address in a1
	addi $sp,$sp,-16
	sw $t5,0($sp)
	sw $t6,4($sp)
	sw $t7,8($sp)
	sw $t8,12($sp)
	sw $ra,16($sp)
	jal inArray	#v1 is the piece t5 is in
	lw $t5,0($sp)
	lw $t6,4($sp)
	lw $t7,8($sp)
	lw $t8,12($sp)
	lw $ra,16($sp)
	addi $sp,$sp,16
	
	#add t6 to t5 piece
	move $a0,$t6	#move t6 to be addded
	move $a1,$v1	#move piece
	move $s2,$s0	#move address
	addi $sp,$sp,-16
	sw $t5,0($sp)
	sw $t6,4($sp)
	sw $t7,8($sp)
	sw $t8,12($sp)
	sw $ra,16($sp)
	jal addToPiece	
	lw $t5,0($sp)
	lw $t6,4($sp)
	lw $t7,8($sp)
	lw $t8,12($sp)
	lw $ra,16($sp)
	addi $sp,$sp,16
	
	#t6 added to t5
	
	j equiAdded
	
equiAdded: #now that both t5,t6 is added to quivalence array
	#replace pixel with the min of t5,t6
	ble $t5,$t6,upSmall	#save t5 if t5<=t6
	#save t6
	sw $t6,($t8)
	addi $t8,$t8,4
	j labelAdded
upSmall: sw $t5,($t8)
	addi $t8,$t8,4
	j labelAdded
	

labelAdded: #now that the label of this pixel is replaced,
#move on to the next
	addi $t7,$t7,1	#increment index
	j looppass1
	
next1:	#pixel=0
	addi $t8,$t8,4	#increment address to img struct
	addi $t7,$t7,1	#increment index
	j looppass1
	
	
looppass1exit: #pass 1 finished

#print labeled img struct
	#move $t8,$s1	#s1 ad of img str
	#addi $t0,$0,0
#print:	ble $s7,$t0,printend
	
	#li $v0,1
	#lw $a0,($t8)
	#syscall
	
	#li $v0,4
	#la $a0,space
	#syscall
	#
	#addi $t8,$t8,4
	#addi $t0,$t0,1
	#j print
#printend:


#loop through equivalence array and find the lowest label in each piece.
#store lowest value in lowest
	move $t8,$s0	#t8 has address of equivalence array
	addi $t1,$0,0	#t1 is no. piece starting at 0
	addi $t9,$0,10	#upper
	la $s6,lowest	#s6 points to lowest
		
outerlow: blt $t9,$t1,outerlowexit	#exit if 10<no.piece
	#find the lowest
	lw $t0,($t8) #load the first int into t0, assume t0 is lowest
	addi $t8,$t8,4

findlow: lw $t3,($t8)
	addi $t8,$t8,4	#increment address
	addi $t5,$0,-1
	beq $t3,$t5,findlowexit	#exit if t3 is -1, reaches end of piece
	beq $t3,$0,findlow	#skip if t3=0, means no content is here
	
	#check if t3 is smaller
	blt $t3,$t0,changelow
	j findlow
changelow: #replace t0 with t3 because t3 is smaller
	move $t0,$t3
	j findlow

findlowexit: #lowest label is found and stored in $t0 (if t0=0, then this piece is empty)
	move $a0,$s6 #a0 points to address of lowest
	
	add $a2,$0,4
	mult $a2,$t1	#current piece index *4 bytes offset
	mflo $a2
	
	add $a0,$a0,$a2	#a2 contains the current piece*4
	#save at s6+no.piece address
	sw $t0,($a0)	#save the lowest at corresponding index
	addi $t1,$t1,1	#increment piece numebr
	j outerlow

outerlowexit: #now lowest is stored with lowest values in 9 pieces




###pass 2
#loop through img struct
#for each pixel, find the pieces its in
#use lowest to get the lowerst val in its pieces
#replace pixel label with lowest
	addi $t1,$0,0	# t1 is index of pixel  starting from 0
	
	mult $s4,$s5
	mflo $s7	#s7 has total number of pixel
	
	move $t9,$s1	#t9 has address of img struct
	addi $t9,$t9,12 #move t9 forward 3 word

pass2: ble $s7,$t1,pass2exit	#exit if current index >=total pixel
	lw $t3,($t9)	#t3 has label
	beq $t3,$0,jnext
	
	#find this label in array
	addi $sp,$sp,-12
	sw $t1,0($sp)	#save index
	sw $t9,4($sp)	#save address
	sw $t3,8($sp)	#save label
	sw $ra,12($sp)	#save ra
	move $a0,$t3
	move $a1,$s0
	jal inArray	#v1 has no. of piece t3 is found
	lw $t1,0($sp)	
	lw $t9,4($sp)	
	lw $t3,8($sp)	
	lw $ra,12($sp)	
	addi $sp,$sp,12
	
	la $a0,lowest	
	addi $sp,$sp,-4
	sw $t3,4($sp)
	addi $t3,$0,4
	mult $v1,$t3
	mflo $v1
	add $a0,$a0,$v1	 #a0=address of lowest+ no.of piece
	lw $t3,4($sp)
	addi $sp,$sp,4
	
	lw $t2,($a0)	#t2 has the lowest vals in this piece
	sw $t2,($t9)	#replace this label with lowest label
	
	addi $t9,$t9,4	#increment address by 4 bytes
	addi $t1,$t1,1	#increment index
	
	j pass2

jnext:	#when the label is empty, skip to next
	addi $t9,$t9,4	#increment address by 4 bytes
	addi $t1,$t1,1	#increment index
	
	j pass2
pass2exit:	#now all labels in img struct is replaced with lowest label

#prints new line
	#li $v0,11
	#addi $a0,$0,10
	#syscall

#print labeled 2 img struct
	#move $t8,$s1	#s1 ad of img str
	addi $t0,$0,0
#print2:	ble $s7,$t0,printend2
	
	#li $v0,1
	#lw $a0,($t8)
	#syscall
	
	#li $v0,4
	#la $a0,space
	#syscall
	
	#addi $t8,$t8,4
	#addi $t0,$t0,1
	#j print2
#printend2:


#now count the number of connected component by counting the non-zero
#labels in lowest
addi $t1,$0,0	#t1 is counter
addi $t0,$0,0	#t0 is index initialize to 0 (0-10 inclusive)
addi $t2,$0,10	#t2 is upper
la $t9,lowest

loopcount: blt $t2,$t0,countexit	#exit if index>10
	addi $t0,$t0,1
	lw $t3,($t9)	#load label from lowest
	addi $t9,$t9,4
	
	bne $t3,$0,incrementcount	#if label not 0
	j loopcount
incrementcount:
	addi $t1,$t1,1
	j loopcount

countexit:
	move $v0,$s1
	move $v1,$t1

	
	j progend


	
	

	
		
			
				
					
						
							
								
									
										
#subroutines			
findAvailable:
	#@params: a0->address of array
	#@returns: v0->next available piece (0-9 inclusive)
	
	#loop through piece. If the first slot is empty, then the piece is empty
	addi $t9,$0,10	#upper
	addi $v0,$0,0	# no.piece
	
loopfind: blt $t9,$v0,findexit	#exit if lower>upper
	move $t4,$a0	#t4 has address
	
	addi $t3,$0,25	
	mult $t3,$v0 	#25 * num of piece= offset
	mflo $t5
	add $t3,$0,4
	mult $t5,$t3	
	mflo $t3	#t3=4*25*no.piece ,offset in bytes
	
	add $t4,$t4,$t3	#t4=address+offset
	lw $t2,($t4)	#load first int from piece
	beq $t2,$0,piecefound
	addi $v0,$v0,1	#increment piece
	j loopfind

findexit: addi $v0,$0,-1 #if not found
piecefound: 
	jr $ra
									
																										
addToPiece:
	#@params: a0->label
	#	  a1->piece no. （0-9）
	#	  a2->address of array
	#@returns: @v0-> 1 (succsuffuly added) 0 (piece is full, somehow not added）
	
	#offset=pieces*25
	addi $t3,$0,25	#t3=25
	mult $t3,$a1	#25*pieces no
	mflo $t0	#t0 contains 25*piece
	addi $t3,$0,4
	mult $t0,$t3	#offset= 25*pieces*4 bytes
	mflo $t0
	
	add $a2,$a2,$t0	#a2 points to address where the piece starts
	addi $v0,$0,0 #by default not added

loopadd:lw $t2,($a2)	#load the int into t2 at address
	addi $t3,$0,-1
	beq $t2,$t3,loopaddexit	#exit if t2=-1
	bne $t2,$0,next	#continue if slot is not avaliable(0)
	#now the slot is avaliable
	sw $a0,($a2)
	addi $v0,$0,1
	j loopaddexit

next:addi $a2,$a2,4
	j loopadd

loopaddexit:
	jr $ra
	





inArray:
	#@param: a0->label (positive int)
	#	 a1->address of equivalence array
	#@returns:
	#	v0-> 1 (is present), 0 (not present)
	#	v1-> # of piece where label is found (meaningless if v0=0)
	
	addi $v1,$0,0	#initialze piece to points to the 0th piece
	addi $v0,$0,0	#by default no present
	
	addi $t9,$0,10	

outerfind: blt $t9,$v1,outerfindexit	#exit if 10<v1
innerfind:	
	lw $t1,($a1)	#load word put into $t1, int, from equivalence array
	addi $a1,$a1,4	#increment address a1
	addi $t8,$0,-1	
	beq $t1,$t8,innerfindexit	#exit inner loop if $t1 is -1
	
	beq $t1,$a0,found	#j to found if t1=label
	j innerfind 

found: #when #t1==label
	addi $v0,$0,1	#v0->1 	
	j outerfindexit

innerfindexit:	#when reaches the end of one piece
	addi $v1,$v1,1	#Increment pointer to piece
	j outerfind

outerfindexit: #either reaches the end of array, or label is found
	jr $ra
	
	
	
deleteLabel:
	#@param: a0->label (positive int)
	#	 a1-> piece (0-10)
	#	 a2->address of equivalence array
	#@returns:
	#	v0-> 1 (is deleted), 0 (not deleted)
	addi $t3,$0,25
	mult $a1,$t3	#25*piece
	mflo $v1
	
	addi $t3,$0,4
	mult $v1,$t3
	mflo $v1	#v1= offset 25*piece*4 bytes
	
	add $a2,$a2,$v1	# a2 address starting at given index
	addi $v0,$0,0	#by default no present
		

innerdel:	
	lw $t1,($a2)	#load word put into $t1, int, from equivalence array
	addi $a2,$a2,4	#increment address a1
	addi $t8,$0,-1	
	beq $t1,$t8,delexit	#exit loop if $t1 is -1
	
	beq $t1,$a0,founddel	#j to found if t1=label
	j innerdel

founddel: #when #t1==label
	addi $a2,$a2,-4	#decrement address to point to where label is found
	sw $0,($a2)	#replace it with 0
	addi $v0,$0,1
	j delexit


delexit: #either reaches the end of array, or label is found
	jr $ra
	
	

	





#@pre: top pixel must exists. IE  current Index-width>=0
#@pram: a0->address of current pixel
#	a1->width
#@returns: v0->label of top pixel (int)
gettop:
	addi $t0,$0,0	#counter
gettoploop:	ble $a1,$t0,gettopexit	#exit of count>=width
	addi $a0,$a0,-4
	addi $t0,$t0,1
	j gettoploop
gettopexit:	#now $a0 points to top pixel
	lw $v0,($a0)	# $v0 has the value of top label
	jr $ra

#@pre: left pixel must exists. ie current index%width!=0
#@pram: a0->address of current pixel
#@returns: v0->label of left pixel
#
getleft:
	addi $a0,$a0,-4
	lw $v0,($a0)
	jr $ra


progend:
connected_components.return:
	move $ra,$s3
	jr $ra
