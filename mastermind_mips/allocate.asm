	.data 
	
	.text
	
.globl allocate_memory # Func to allocate memory (size)
allocate_memory:
	# a0 has size
	li	$v0, 9							# syscall for malloc
	syscall
	jr	$ra