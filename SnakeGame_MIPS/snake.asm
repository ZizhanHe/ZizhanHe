# TODO: modify the info below
# Student ID: 260943211
# Name: Herbie He
# TODO END
########### COMP 273, Winter 2022, Assignment 4, Question 3 - Snake ###########

# Constant definition. You can use them like using an immediate.
# color definition:
.eqv BLACK	0x00000000
.eqv RED	0x00ff0000
.eqv GREEN	0x0000ff00
.eqv BLUE	0x000000ff
.eqv YELLOW	0x00ffff00
.eqv BROWN	0x00994c00
.eqv GRAY	0x00f0f0f0
.eqv WHITE	0x00ffffff

# tile definition
.eqv EMPTY	BLACK
.eqv SNAKE	WHITE
.eqv FOOD	YELLOW
.eqv RED_PILL	RED
.eqv BLUE_PILL	BLUE
.eqv WALL	BROWN

# Direction definition
.eqv DIR_RIGHT	0
.eqv DIR_DOWN	1
.eqv DIR_LEFT	2
.eqv DIR_UP  3

# game state definition
.eqv STATE_NORMAL	0
.eqv STATE_PAUSE	1
.eqv STATE_RESTART	2
.eqv STATE_EXIT		3

# some constants for buffer
.eqv WIDTH	64
.eqv HEIGHT	32
.eqv DISPLAY_BUFFER_SIZE	0x2000
.eqv SNAKE_BUFFER_SIZE		0x2000

# initial postion of the snake
.eqv INIT_HEAD_X	32
.eqv INIT_HEAD_Y	16
.eqv INIT_TAIL_X	31
.eqv INIT_TAIL_Y	16

# initial length of the snake
.eqv INIT_LENGTH	2

# maximum number of pills
.eqv MAX_NUM_PILLS	10

# TODO: add any constants here you if you need


# TODO END


.data
displayBuffer:	.space	DISPLAY_BUFFER_SIZE	# 64x32 display buffer. Each pixel takes 4 bytes.
snakeSegment:	.space	SNAKE_BUFFER_SIZE	# Array to store the offsets of the snake segments in the display buffer.
						# E.g., head_offset, 2nd_segment_offset, ..., tail_offset
						# Each offset takes 4 bytes.
snakeLength:	.word	INIT_LENGTH		# length of the snake
headX:		.word	INIT_HEAD_X		# head position x
headY:		.word	INIT_HEAD_Y		# head position y
numPills:	.word	0	# number of pills (red and blue)
direction:	.word	0	# moving direction of the snake head:
				#	0: right
				#	1: down
				#	2: left
				#	3: up
state:		.word	0	# game state:
				#	0: normal
				#	1: pause
				#	2: retstart
				#	3: exit

wallFile:	.asciiz "wall.txt"	#wall file that determines the wall
readBuffer: .space 1
wallBuffer: .space 8
score:		.word	0	# score in the game. increase by 1 everying time eating a regular food
msgScore:	.asciiz "Score: "
.align 2
timeInterval:	.word   100
incSpeed:	.float 0.833333
decSpeed:	.float 1.25

# TODO: add any variables here you if you need


# TODO END


.text
main:
	jal initGame
gameLoop:
	li $v0, 32
	lw $a0, timeInterval
	syscall
	
# TODO: objective 1, Handle Keyboard Input using MMIO 
	
	#use polling to check if user entered a letter
	#get ready bit
	lui $t3, 0xffff	
	lw $t2,($t3)	#loads from adrs ffff0000 ro $t2
	andi $t2,$t2,0x0001	#get ready bit in t2
	beq $t2,$0,endhandle	#if not key is pressed, continue program
	#key is pressed, read the key
	lw $t1,4($t3)	#reads from ffff0004, put char into t1
	
	addi $t4,$0,119	#ascii for 'w'
	beq $t1,$t4,handleW	#branch if key enter is 'w'
	
	addi $t4,$0,115	#ascii for 's'
	beq $t1,$t4,handleS	#branch if key entered is 's'
	
	addi $t4,$0,97	#ascii for 'a'
	beq $t1,$t4,handleA	#branch if key entered is 'a'
	
	addi $t4,$0,100	#ascii for 'd'
	beq $t1,$t4,handleD	#branch if key entered is 'd'
	
	addi $t4,$0,113	#ascii for 'q'
	beq $t1,$t4,handleQ	#branch if key entered is 'q'
	
	addi $t4,$0,114	#ascii for 'r'
	beq $t1,$t4,handleR	#branch if key entered is 'r'
	
	addi $t4,$0,112	#ascii for 'p'
	beq $t1,$t4,handleP	#branch if key entered is 'p'
	
	j endhandle
	
handleP:#check the current state
	la $t8,state
	lw $t2,($t8)	#load current state in t2
	
	beq $t2,$0,pause #b to pause if current state is normal
	#current state is pause
	sw $0,($t8)	#save 0 normal to state
	j endhandle

pause:	addi $t0,$0,1	#1 for pause
	sw $t0,($t8)
	j endhandle

handleR:#set the state to 2 restart
	la $t8,state
	addi $t0,$0,2
	sw $t0,($t8)
	j endhandle
	
handleQ: #set the state to 3 exit
	la $t8,state
	addi $t0,$0,3	#3 for exit
	sw $t0,($t8)	#save exit in state
	j endhandle
	
handleD:#change the direction to right
	#check if the current direction is left
	la $t8,direction
	lw $t5,($t8)	#load current direction (int) into t5
	
	addi $t0,$0,2	#2 for left
	beq $t5,$t0,endhandle #do nothing if current direction is left
	
	#else change direction to right
	addi $t0,$0,0	#0 for right
	sw $t0,($t8)	#save left into direction
	j endhandle


handleA:#change the direction to left
	#check if the current direction is right
	la $t8,direction
	lw $t5,($t8)	#load current direction (int) into t5
	
	addi $t0,$0,0	#0 for right
	beq $t5,$t0,endhandle #do nothing if current direction is right
	
	#else change direction to left.
	addi $t0,$0,2	#2 for left
	sw $t0,($t8)	#save left into direction
	j endhandle

handleS:#change the direction to down
	#check if the current direction is up
	la $t8,direction
	lw $t5,($t8)	#load current direction (int) into t5
	
	addi $t0,$0,3	#3 for up
	beq $t5,$t0,endhandle #do nothing if current direction is up
	
	#else change direction to down.
	addi $t0,$0,1	#1 for up
	sw $t0,($t8)	#save down into direction
	j endhandle

handleW:#change the direction to up
	#check if the current direction is down
	la $t8,direction
	lw $t5,($t8)	#load current direction (int) into t5
	
	addi $t0,$0,1	#1 for down
	beq $t5,$t0,endhandle #do nothing if current direction is down
	
	#else change direction to up.
	addi $t0,$0,3	#3 for up
	sw $t0,($t8)	#save up into direction
	j endhandle




endhandle:
	


# TODO END
	
	lw $t0, state
	beq $t0, STATE_NORMAL, main.normal
	beq $t0, STATE_PAUSE, main.pause
	beq $t0, STATE_RESTART, main.restart
	j main.exit
main.normal:
	jal updateDisplay	
	j gameLoop
main.pause:
	j gameLoop
main.restart:
	jal initGame
	j gameLoop	
main.exit:
	la $a0, msgScore
	li $v0, 4
	syscall
	lw $a0, score
	li $v0, 1
	syscall
	li $v0, 10
	syscall
	
	
# void initGame()
initGame:
	sub $sp, $sp, 4
	sw $ra, ($sp)
	
	la $a0, displayBuffer
	li $a1, DISPLAY_BUFFER_SIZE
	jal clearBuffer
	

	
	lw $s4,($sp)
	addi $sp,$sp,4
	
	jal initMap	#create wall
	
	sub $sp,$sp,4
	sw $s4,($sp)
	
	# initialize variables
	li $t0, INIT_LENGTH
	sw $t0, snakeLength
	li $t0, INIT_HEAD_X
	sw $t0, headX
	li $t0, INIT_HEAD_Y
	sw $t0, headY
	li $t0, DIR_RIGHT
	sw $t0, direction
		
	li $a0, INIT_HEAD_X
	li $a1, INIT_HEAD_Y
	jal pos2offset
	li $t0, SNAKE
	sw $t0, displayBuffer($v0)	# draw head pixel
	sw $v0, snakeSegment		# head offset

	li $a0, INIT_TAIL_X
	li $a1, INIT_TAIL_Y
	jal pos2offset
	li $t0, SNAKE
	sw $t0, displayBuffer($v0)	# draw tail pixel
	sw $v0, snakeSegment+4		# tail offset
	
	sw $zero, numPills
	li $t0, STATE_NORMAL
	sw $t0, state
	sw $zero, score
	
	# set seed for corresponding pseudorandom number generator using system time
	li $v0, 30
	syscall
	move $a1, $a0
	li $a0, 0	# ID = zero
	li $v0, 40
	syscall	
	
	# spawn food
	jal spawnFood

	lw $ra, ($sp)
	add $sp, $sp, 4	
	jr $ra
	
	
# void updateDisplay()
updateDisplay:
	sub $sp, $sp, 8
	sw $ra, ($sp)
	sw $s0, 4($sp)
	
	lw $a0, headX
	lw $a1, headY
	lw $t0, direction
	beq $t0, DIR_RIGHT, updateDisplay.goRight
	beq $t0, DIR_DOWN, updateDisplay.goDown
	beq $t0, DIR_LEFT, updateDisplay.goLeft
	beq $t0, DIR_UP, updateDisplay.goUp
updateDisplay.goRight:
	add $a0, $a0, 1
	blt $a0, WIDTH, updateDisplay.headUpdateDone
	sub $a0, $a0, WIDTH	# wrap over if exceeds boundary
	j updateDisplay.headUpdateDone
updateDisplay.goDown:
	add $a1, $a1, 1
	blt $a1, HEIGHT, updateDisplay.headUpdateDone
	sub $a1, $a1, HEIGHT	# wrap over if exceeds boundary
	j updateDisplay.headUpdateDone
updateDisplay.goLeft:
	sub $a0, $a0, 1
	bge $a0, 0, updateDisplay.headUpdateDone
	add $a0, $a0, WIDTH	# wrap over if exceeds boundary
	j updateDisplay.headUpdateDone
updateDisplay.goUp:
	sub $a1, $a1, 1
	bge $a1, 0, updateDisplay.headUpdateDone
	add $a1, $a1, HEIGHT	# wrap over if exceeds boundary
	j updateDisplay.headUpdateDone
updateDisplay.headUpdateDone:
	sw $a0, headX
	sw $a1, headY
	jal pos2offset
	move $s0, $v0		# store the head offset because we need it later

	lw $t0, displayBuffer($s0) # what is in the next posion of head?
	beq $t0, EMPTY, updateDisplay.empty
	beq $t0, FOOD, updateDisplay.food
	beq $t0, RED_PILL, updateDisplay.redPill
	beq $t0, BLUE_PILL, updateDisplay.bluePill
	# else hit into bad thing
	li $t0, STATE_EXIT
	sw $t0, state
	j updateDisplay.ObjectDetectionDone
	
updateDisplay.empty:	# nothing
	li $t0, SNAKE
	sw $t0, displayBuffer($s0)	# draw head pixel
	
	# erase old tail in display (set color to black)
	lw $t0, snakeLength
	sub $t0, $t0, 1
	sll $t0, $t0, 2
	lw $t1, snakeSegment($t0)	# load the tail offset
	li $t2, EMPTY
	sw $t2, displayBuffer($t1)
	
	j updateDisplay.ObjectDetectionDone
	
updateDisplay.food:	#regular food
	li $t0, SNAKE
	sw $t0, displayBuffer($s0)	# draw head pixel
	lw $t0, snakeLength
	add $t0, $t0, 1
	sw $t0, snakeLength	# increase snake length
	
	jal spawnFood
	lw $t0, score
	add $t0, $t0, 1
	sw $t0, score
	
	j updateDisplay.ObjectDetectionDone
	
updateDisplay.redPill:
	li $t0, SNAKE
	sw $t0, displayBuffer($s0)	# draw head pixel
	
	# erase old tail in display (set color to black)
	lw $t0, snakeLength
	sub $t0, $t0, 1
	sll $t0, $t0, 2
	lw $t1, snakeSegment($t0)	# load the tail offset
	li $t2, EMPTY
	sw $t2, displayBuffer($t1)
	
	lw $t0, numPills
	sub $t0, $t0, 1
	sw $t0, numPills
	
	# increase game speed
	lw $t0, timeInterval
	mtc1 $t0, $f0
	cvt.s.w $f0, $f0
	l.s $f1, incSpeed
	mul.s $f0, $f0, $f1
	cvt.w.s $f0, $f0
	mfc1 $t0, $f0
	sw $t0, timeInterval
	
	j updateDisplay.ObjectDetectionDone
	
updateDisplay.bluePill:
	li $t0, SNAKE
	sw $t0, displayBuffer($s0)	# draw head pixel
	
	# erase old tail in display (set color to black)
	lw $t0, snakeLength
	sub $t0, $t0, 1
	sll $t0, $t0, 2
	lw $t1, snakeSegment($t0)	# load the tail offset
	li $t2, EMPTY
	sw $t2, displayBuffer($t1)
	
	lw $t0, numPills
	sub $t0, $t0, 1
	sw $t0, numPills
	
	# decrease game speed
	lw $t0, timeInterval
	mtc1 $t0, $f0
	cvt.s.w $f0, $f0
	l.s $f1, decSpeed
	mul.s $f0, $f0, $f1
	cvt.w.s $f0, $f0
	mfc1 $t0, $f0
	sw $t0, timeInterval
	
	j updateDisplay.ObjectDetectionDone

updateDisplay.ObjectDetectionDone:
	
	
	# update snake segments
	# for i = length-1 to 1
	#	snakeSegment[i] = snakeSegment[i-1]
	# snakeSegment[0] = new head position (stored in $s0)
	lw $t0, snakeLength	# index i
updateDisplay.snakeUpdateLoop:
	sub $t0, $t0, 1
	blt $t0, 1, updateDisplay.snakeUpdateLoopDone
	sll $t1, $t0, 2		# convert index to offset
	sub $t2, $t1, 4		# offset of previous segment
	lw $t4, snakeSegment($t2)
	sw $t4, snakeSegment($t1) # snakeSegment[i] = snakeSegment[i-1]
	j updateDisplay.snakeUpdateLoop
updateDisplay.snakeUpdateLoopDone:
	sw $s0, snakeSegment	# update head offset in snakeSegment
	
	lw $ra, ($sp)
	lw $s0, 4($sp)
	add $sp, $sp, 8
	jr $ra
	

# int pos2offset(int x, int y)
# offset = (y * WIDTH + x) * 4
# Note that each pixel takes 4 bytes!
pos2offset:
	mul $v0, $a1, WIDTH
	add $v0, $v0, $a0
	sll $v0, $v0, 2
	jr $ra


# void spawnFood()
spawnFood:
	sub $sp, $sp, 4
	sw $ra, ($sp)
	
	# spawn regular food (yellow)
spawnFood.regular:
	li $a0, WIDTH	# range: 0 <= x < WIDTH
	jal randInt
	move $t0, $v0,	# position x
	li $a0, HEIGHT	# range: 0 <= y < HEIGHT
	jal randInt
	move $t1, $v0,	# position y
	move $a0, $t0
	move $a1, $t1
	jal pos2offset
	lw $t0, displayBuffer($v0)		# get "thing" on (x, y)
	bne $t0, EMPTY, spawnFood.regular	# find another place if it is not empty
	li $t0 FOOD
	sw $t0, displayBuffer($v0)	# put the food
	
#Spwan Blue pills
#check if numofpills has exceeds MaxPills
spawnPill:
	la $t8,numPills	#adrs of numPills in t8
	lw $t4, ($t8)	#load num of pills into t4
	add $t9,$0,MAX_NUM_PILLS #t9 has max num of pills
	ble $t9, $t4, endSpawn	#skip if num of pills>=MAX_NUM_PILLS

	#spawn red pill! 20% chance!
	addi $a0,$0,5	
	jal randInt # v0 is a randInt from 0,1,2,3,4. It has 20% to be 0
	bne $v0,$0,spawnBlue	#if v0 !=0, then dont spawn red pill,j to spawn blue pill
	#spawn red pill
	lw $t4,($t8)
	addi $t4,$t4,1
	sw $t4,($t8)	#increment num of pills
		
	#find a spot for pill
findposR:	
	li $a0, WIDTH	# range: 0 <= x < WIDTH
	jal randInt
	move $t0, $v0,	# position x
	li $a0, HEIGHT	# range: 0 <= y < HEIGHT
	jal randInt
	move $t1, $v0,	# position y
	move $a0, $t0
	move $a1, $t1
	jal pos2offset
	lw $t0, displayBuffer($v0)		# get "thing" on (x, y)
	bne $t0, EMPTY, findposR# find another place if it is not empty
	li $t0 RED_PILL
	sw $t0, displayBuffer($v0)	# put the redpill
	#end spawn red pill

spawnBlue:
	#check if exceeds MAX num
	la $t8,numPills	#adrs of numPills in t8
	lw $t4, ($t8)	#load num of pills into t4
	add $t9,$0,MAX_NUM_PILLS #t9 has max num of pills
	ble $t9, $t4, endSpawn	#skip if num of pills>=MAX_NUM_PILLS
	#15% chance
	addi $a0,$0,100	
	jal randInt	#v0 has 15% chance of <15
	addi $t1,$0,15
	ble $t1,$v0,endSpawn	#j to end if v0>=15, blue pill not spawn
	
	#spawn blue
	lw $t4,($t8)
	addi $t4,$t4,1
	sw $t4,($t8)	#increment num of pills

findposB:	
	li $a0, WIDTH	# range: 0 <= x < WIDTH
	jal randInt
	move $t0, $v0,	# position x
	li $a0, HEIGHT	# range: 0 <= y < HEIGHT
	jal randInt
	move $t1, $v0,	# position y
	move $a0, $t0
	move $a1, $t1
	jal pos2offset
	lw $t0, displayBuffer($v0)		# get "thing" on (x, y)
	bne $t0, EMPTY, findposB# find another place if it is not empty
	li $t0 BLUE_PILL
	sw $t0, displayBuffer($v0)	# put the blue pill
	#end spawn blue pill
		

endSpawn:



# TODO END
	
	lw $ra, ($sp)
	add $sp, $sp, 4
	jr $ra


# void clearBuffer(char* buffer, int size)
clearBuffer:
	li $t0, 0
clearBuffer.loop:
	bge $t0, $a1, clearBuffer.return
	add $t1, $a0, $t0
	sb $zero, ($t1)
	add $t0, $t0, 1
	j clearBuffer.loop
clearBuffer.return:
	jr $ra


# int randInt(int max)
# generate an random integer n where 0 <= n < max
randInt:
	move $a1, $a0
	li $a0, 0
	li $v0, 42
	syscall
	move $v0, $a0
	jr $ra
	
# void initMap()
initMap:
# TODO: objective 3, Add Walls
# load the map file you create and add wall to displayBuffer
	addi $sp,$sp,-36
	sw $ra,($sp)
	sw $t0,4($sp)
	sw $t1,8($sp)
	sw $t2,12($sp)
	sw $t3,16($sp)
	sw $t4,20($sp)
	sw $s0,24($sp)
	sw $s6,28($sp)
	sw $t5,32($sp)
	sw $t6,36($sp)
	move $s5,$ra
	
	
	#DisplayBuffer is separated into 8 grid, 0,1,2,3,4,5,6,7. Each is 16*16 square (since whole buffer is 32*64
	#	****
	#	****
	#For each grid, user can customize their wall from 8 wall patterns provided.
	# 0 -no wall
	# 1 -corner with openning towards lower right
	# 2 -corner with openning towards upper right
	# 3 -corner with openning towards lower left
	# 4 -corner with openning towards upper left
	# 5 -vretical wall
	# 6 -horizontal wall
	# 7 -diagonal (lower left to uppper right)
	# 8 -diagonal (upper left to lower right)
	
	#in wall.txt, there should be 8 lines denoting the wall pattern for each line (separated by \n).
	
	#open wall file
	la  $a0,wallFile
	addi $a1,$0,0	#flag for read
	addi $a2,$0,0
	li $v0,13
	syscall

	move $s6,$v0	#file descript in $s6
	
	addi $t0,$0,0	#counter
	addi $t1,$0,8
	
readWall:
	ble $t1,$t0,readWallend	#exit if counter>=8
	
	move $a0,$s6
	la $a1,readBuffer
	addi $a2,$0,1	#read 1 byte
	li $v0,14
	syscall
	beq $v0,$0,readWallend	#exit if end of file
	
	la $t8,readBuffer
	lb $t4,($t8)	#get char read
	beq $t4,10,readWall	#skip if char is \n
	#if not \n save it in wallBuffer
	
	la $t7,wallBuffer
	add $t7,$t7,$t0	#get adrs=adrs+offset
	sb $t4,($t7)
	
	addi $t0,$t0,1	#increment counter
	j readWall
readWallend:
	#now wallBuffer contains wall pattern for all grids (ascii)
	#draw wall
	move $a0,$s6	#close file
	li $v0,16
	syscall
	
	la $t4,wallBuffer
	

	addi $t1,$0,0	#y counter 0,1
	
	

	
	#t0-x
	#t1-y
	

drawloop:
	addi $t6,$0,2	#y upper
	ble $t6,$t1,outerdrawexit	#loop row

	addi $t0,$0,0	#initialize x to 0  (0,1,2,3)
innerdraw:
	addi $t5,$0,4	#x upper
	ble $t5,$t0,innerdrawexit
	
	#saves t0,t1,t4
	addi $sp,$sp,-8
	sw $t0,($sp)
	sw $t1,4($sp)
	sw $t4,8($sp)
	
	addi $t3,$0,16	#t3=16
	mult $t0,$t3	#x*16
	mflo $a0
	mult $t1,$t3 	#y*16
	mflo $a1
	#a0, a1 has initial x, y
		
	#determine which wall to draw
	addi $t3,$0,4
	mult $t1,$t3
	mflo $t3
	
	add $t3,$t3,$t0	#t3=4*y+x
	add $t3,$t4,$t3	#t3=adrs to current wall pattern
	
	lb $t2,($t3)	#t2 has no. of wall pattern
	
	addi $t3,$0,48 #ascii for 0
	beq $t2,$t3,drawnext
	#t2!=0
	addi $t3,$0,49	#ascii for 1
	bne $t2,$t3,check2
	#t2==1	
	jal drawCorner1
	j drawnext
	
check2:
	addi $t3,$0,50	#ascii for 2
	bne $t2,$t3,check3
	#t2==2
	jal drawCorner2
	j drawnext
check3:
	addi $t3,$0,51	#ascii for 3
	bne $t2,$t3,check4
	#t2==2
	jal drawCorner3
	j drawnext
check4:
	addi $t3,$0,52	#ascii for 4
	bne $t2,$t3,check5
	#t2==2
	jal drawCorner4
	j drawnext
check5:
	addi $t3,$0,53	#ascii for 5
	bne $t2,$t3,check6
	#t2==2
	jal vertical
	j drawnext

check6:
	addi $t3,$0,54	#ascii for 6
	bne $t2,$t3,check7
	#t2==2
	jal horizontal
	j drawnext
check7:
	addi $t3,$0,55	#ascii for 7
	bne $t2,$t3,check8
	#t2==2
	jal diagonal1
	j drawnext
check8:
	addi $t3,$0,56	#ascii for 8
	bne $t2,$t3,drawnext
	#t2==8
	jal diagonal2
	j drawnext

drawnext:
	#finished drawing one wall
	
	lw $t0,($sp)
	lw $t1,4($sp)
	lw $t4,8($sp)
	addi $sp,$sp,8
	
	addi $t0,$t0,1	#increment x
	j innerdraw

innerdrawexit: #one row has been drew
	
	addi $t1,$t1,1
	j drawloop

outerdrawexit:
		
	lw $ra,($sp)
	lw $t0,4($sp)
	lw $t1,8($sp)
	lw $t2,12($sp)
	lw $t3,16($sp)
	lw $t4,20($sp)
	lw $s0,24($sp)
	lw $s6,28($sp)
	lw $t5,32($sp)
	lw $t6,36($sp)
	addi $sp,$sp,36
	move $ra,$s5
	jr $ra
	
	#la $t8,wallBuffer
	
	#lb $t2,($t8)	#load first grid
	


#todo end

## $a0->x zero cooor of grid
## $a1->y zero coor of grid
drawCorner1:
	addi $sp,$sp,-4
	sw $ra,($sp)
	
	addi $a0,$a0,7	
	addi $a1,$a1,7	# (7,7)
	move $t6,$a0	
	move $t7,$a1	#saves a0,a1 (7,7)
	#draw -
	addi $t5,$a0,8 # (7,7)->(14,7) inclusive, t5=14
corner11:
	blt $t5,$a0,corner11exit	#exit if x>14
	jal pos2offset	#v0 offset
	la $t8,displayBuffer
	add $t8,$t8,$v0	#adrs=adrs+offset
	li $t1,WALL
	sw $t1,($t8)	#save into bufferDisaplay
	
	addi $a0,$a0,1	#increment x
	j corner11
corner11exit:
	#draw |
	move $a0,$t6
	move $a1,$t7	# a0,a1 are (7,7) again
	addi $t5,$a1,8 # (7,7)->(14,7) inclusive, t5=14
corner12:
	blt $t5,$a1,corner12exit	#exit if y>14
	jal pos2offset	#v0 offset
	la $t8,displayBuffer
	add $t8,$t8,$v0	#adrs=adrs+offset
	li $t1,WALL
	sw $t1,($t8)	#save into bufferDisaplay
	
	addi $a1,$a1,1	#increment y
	j corner12
corner12exit:

	lw $ra,($sp)
	addi $sp,$sp,4
	jr $ra
	
	
	
	
## $a0->x zero cooor of grid
## $a1->y zero coor of grid
drawCorner2:
	addi $sp,$sp,-4
	sw $ra,($sp)
	
	#saves y-0
	move $t9,$a1
	
	addi $a0,$a0,7	
	addi $a1,$a1,7	# (7,7)
	
	move $t6,$a0
	move $t7,$a1

	#draw -
	addi $t5,$a0,8 # (7,7)->(14,7) inclusive, t5=14
corner21:
	blt $t5,$a0,corner21exit	#exit if x>14
	jal pos2offset	#v0 offset
	la $t8,displayBuffer
	add $t8,$t8,$v0	#adrs=adrs+offset
	li $t1,WALL
	sw $t1,($t8)	#save into bufferDisaplay
	
	addi $a0,$a0,1	#increment x
	j corner21
corner21exit:
	#draw |
	move $a0,$t6
	move $a1,$t7	# a0,a1 are (7,7) again
	
corner22:
	blt $a1,$t9,corner22exit	#exit if y<y0
	jal pos2offset	#v0 offset
	la $t8,displayBuffer
	add $t8,$t8,$v0	#adrs=adrs+offset
	li $t1,WALL
	sw $t1,($t8)	#save into bufferDisaplay
	
	addi $a1,$a1,-1	#decrement y
	j corner22
corner22exit:
	
	lw $ra,($sp)
	addi $sp,$sp,4
	jr $ra


## $a0->x zero cooor of grid
## $a1->y zero coor of grid
drawCorner3:
	addi $sp,$sp,-4
	sw $ra,4($sp)
	
	move $t2,$a0	#t2 initial position of x

	addi $a0,$a0,7	
	addi $a1,$a1,7	# (7,7)
	
	move $t6,$a0	
	move $t7,$a1	#saves a0,a1 (7,7)
	#draw -
corner31:
	blt $a0,$t2,corner31exit	#exit if x<x0
	jal pos2offset	#v0 offset
	la $t8,displayBuffer
	add $t8,$t8,$v0	#adrs=adrs+offset
	li $t1,WALL
	sw $t1,($t8)	#save into bufferDisaplay
	
	addi $a0,$a0,-1	#increment x
	j corner31
corner31exit:
	#draw |
	move $a0,$t6
	move $a1,$t7	# a0,a1 are (7,7) again
	addi $t5,$a1,8	#t5=y+7
	
corner32:
	blt $t5,$a1,corner32exit	#exit if y>14
	jal pos2offset	#v0 offset
	la $t8,displayBuffer
	add $t8,$t8,$v0	#adrs=adrs+offset
	li $t1,WALL
	sw $t1,($t8)	#save into bufferDisaplay
	
	addi $a1,$a1,1	#increment y
	j corner32
corner32exit:

	lw $ra,4($sp)
	addi $sp,$sp,4
	jr $ra

## $a0->x zero cooor of grid
## $a1->y zero coor of grid
drawCorner4:
	addi $sp,$sp,-4
	sw $ra,($sp)
	
	move $t2,$a0	#t2 initial position of x
	move $t9,$a1	#t9 initial position of y

	addi $a0,$a0,7	
	addi $a1,$a1,7	# (7,7)
	
	move $t6,$a0	
	move $t7,$a1	#saves a0,a1 (7,7)
	#draw -
corner41:
	blt $a0,$t2,corner41exit	#exit if x<x0
	jal pos2offset	#v0 offset
	la $t8,displayBuffer
	add $t8,$t8,$v0	#adrs=adrs+offset
	li $t1,WALL
	sw $t1,($t8)	#save into bufferDisaplay
	
	addi $a0,$a0,-1	#increment x
	j corner41
corner41exit:
	#draw |
	move $a0,$t6
	move $a1,$t7	# a0,a1 are (7,7) again
	
corner42:
	blt $a1,$t9,corner42exit	#exit if y<y0
	jal pos2offset	#v0 offset
	la $t8,displayBuffer
	add $t8,$t8,$v0	#adrs=adrs+offset
	li $t1,WALL
	sw $t1,($t8)	#save into bufferDisaplay
	
	addi $a1,$a1,-1	#decrement y
	j corner42
corner42exit:

	lw $ra,($sp)
	addi $sp,$sp,4
	jr $ra


## $a0->x zero cooor of grid
## $a1->y zero coor of grid
vertical:	
	sub $sp,$sp,4
	sw $ra,($sp)
	
	addi $a0,$a0,7	#x=7
	addi $t5,$a1,15	#y upper 15

verticallp:
	blt $t5,$a1,verticallpexit	#exit if y>15
	jal pos2offset
	la $t8,displayBuffer
	add $t8,$t8,$v0	#adrs=adrs+offset
	li $t1,WALL
	sw $t1,($t8)	#save into bufferDisaplay
	
	addi $a1,$a1,1	#increment y
	j verticallp
verticallpexit:
	lw $ra,($sp)	
	add $sp,$sp,4
	jr $ra
	
## $a0->x zero cooor of grid
## $a1->y zero coor of grid
horizontal:	
	sub $sp,$sp,4
	sw $ra,($sp)
	
	addi $a1,$a1,7	#y=7
	addi $t5,$a0,15	#x upper 15

horizontallp:
	blt $t5,$a0,horizontallpexit	#exit if y>15
	jal pos2offset
	la $t8,displayBuffer
	add $t8,$t8,$v0	#adrs=adrs+offset
	li $t1,WALL
	sw $t1,($t8)	#save into bufferDisaplay
	
	addi $a0,$a0,1	#increment x
	j horizontallp
horizontallpexit:
	lw $ra,($sp)	
	add $sp,$sp,4
	jr $ra

## $a0->x zero cooor of grid
## $a1->y zero coor of grid
diagonal1:	
	sub $sp,$sp,4
	sw $ra,($sp)
	
	move $t5,$a1
	addi $a1,$a1,15	#y=y+15

diagonal1lp:
	blt $a1,$t5,diagonal1lpexit	#exit if y<0
	jal pos2offset
	la $t8,displayBuffer
	add $t8,$t8,$v0	#adrs=adrs+offset
	li $t1,WALL
	sw $t1,($t8)	#save into bufferDisaplay
	
	addi $a0,$a0,1	#increment x
	addi $a1,$a1,-1	#decrement y
	j diagonal1lp
diagonal1lpexit:
	lw $ra,($sp)	
	add $sp,$sp,4
	jr $ra


## $a0->x zero cooor of grid
## $a1->y zero coor of grid
diagonal2:	
	sub $sp,$sp,4
	sw $ra,($sp)
	
	
	addi $t5,$a1,15	#t5=upper y

diagonal2lp:
	blt $t5,$a1,diagonal2lpexit	#exit if y>15
	jal pos2offset
	la $t8,displayBuffer
	add $t8,$t8,$v0	#adrs=adrs+offset
	li $t1,WALL
	sw $t1,($t8)	#save into bufferDisaplay
	
	addi $a0,$a0,1	#increment x
	addi $a1,$a1,1	#increment y
	j diagonal2lp
diagonal2lpexit:
	lw $ra,($sp)	
	add $sp,$sp,4
	jr $ra




	
# TODO: add any helper functions here you if you need



# TODO END
