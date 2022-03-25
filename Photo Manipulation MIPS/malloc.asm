.data
.align 2
memoryErrMessage:	.asciiz "Out Of Memory\n"
.text
.globl malloc
malloc:
	# $a0 -> number of bytes to allocate
	################## return ##################
	# $v0 -> allocated address.
  	li    	$v0, 9                 # system call code for sbrk
  	syscall                        # allocate memory
  	bnez  	$v0, malloc.return     # Did malloc fail?                   
	la 	$a0, memoryErrMessage
	li 	$v0,4
	syscall
	li	$v0,-1
malloc.return:
	jr 	$ra	

