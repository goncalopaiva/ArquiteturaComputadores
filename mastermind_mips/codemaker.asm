.macro random_int_
addi	$v0, $zero, 42
syscall
.end_macro

#----------DATA------------#
	.data
	
#----------TEXT------------#
	.text
	
.globl codemaker_combination # Func to create codemakers input (board_column, &alphabet, alphabet_size)
codemaker_combination:
	add	$sp, $sp, -20			
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$a0, 12($sp)
	sw	$a1, 16($sp)
	
	jal	allocate_codemaker_combination				# allocate_codemaker_combination (board_columns)
	la 	$s1, ($v0)						# &codemaker_input
	
	add	$s0, $zero, $zero					# i = 0
begin_codemaker_input:
	beq	$s0, $a0, codemaker_input_end				# if (i == board_columns) goto codemaker_input_end
	move	$t0, $a1						# $t0 = &alphabet
	move	$t1, $s1						# $t1 = &codemaker_input
	move	$a1, $a2						# upperbound of random int syscall (0 - alpha_size)
	random_int_
	add	$t0, $t0, $a0						# $t0 = alphabet + random_int_
	lb	$t0, 0($t0)						# $t0 = alphabet [random_int_]
	add	$t1, $t1, $s0						# $t1 = codemaker_input + i
	sb	$t0, ($t1)						# codemaker_input[i] = alphabet(random_int_)
	addi	$s0, $s0, 1 						# i++
	lw	$a0, 12($sp)						# $a0 = &colors
	lw	$a1, 16($sp)						# $a1 = &codemaker_input
	j	begin_codemaker_input
codemaker_input_end:
	move	$v0, $s1						# return &codemaker_input
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)						
	lw	$s1, 8($sp)
	add	$sp, $sp, 20
	jr	$ra

		
# Func to allocate mem for codemaker_input
allocate_codemaker_combination:
	# $a0 already has alphabet_size
	li	$v0, 9							# syscall for malloc
	syscall
	jr	$ra