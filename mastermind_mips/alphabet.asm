.macro read_int_
li	$v0, 5
syscall
.end_macro

.macro read_char_
li	$v0, 12
syscall
.end_macro

.macro print_char_
li	$v0, 11
syscall
.end_macro

.macro print_white_space_
li	$v0, 4
la	$a0, white_space
syscall
.end_macro

.macro alphabet_size_msg_
li	$v0, 4
la	$a0, alphabet_size_msg
syscall
.end_macro

.macro insert_alphabet_msg_
li	$v0, 4
la	$a0, insert_alphabet_msg
syscall
.end_macro

.macro insert_new_line_
li	$v0, 4
la	$a0, insert_new_line
syscall
.end_macro
	
#----------DATA------------#
	.data
alphabet_size_msg: .asciiz "Enter alphabet size: \n"
insert_alphabet_msg: .asciiz "Enter an alphabet for available colors: "
white_space: .asciiz " "
insert_new_line: .asciiz "\n"
	.align 2
	
#----------TEXT------------#
	.text
	
.globl set_alphabet # Func to set an alphabet for available_colors
set_alphabet:
	add	$sp, $sp, -16
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	
	alphabet_size_msg_
	read_int_
	move	$s0, $v0						# alphabet size
	
	move	$a0, $s0						
	jal	allocate_memory_alphabet				# allocate_memory_alphabet (alphabet_size)
	move	$s1, $v0						# &alphabet
	
	insert_alphabet_msg_
	li	$s2, 0							# i = 0
	move	$t0, $s1
begin_set_alpha:
	bge	$s2, $s0, end_set_alpha					# if (i >= alphabet_size) goto end_set_alpha
	read_char_
	sb	$v0, ($t0)						# alphabet [i] = read_char_
	addi	$t0, $t0, 1						# alphabet + i
	addi	$s2, $s2, 1						# i ++
	j	begin_set_alpha
end_set_alpha:
	move	$v0, $s0						# return size of alphabet
	move	$v1, $s1						# return &alphabet
	 
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	add	$sp, $sp, 16
	jr	$ra
	

.globl print_alphabet # Func to print alphabete (&alphabete, alpha_size)
print_alphabet: 
	add	$sp, $sp, -8
	sw	$s0, 0($sp)
	sw	$s1, 4($sp)
	
	li	$s0, 0
	move	$s1, $a0						# &alphabete
begin_print_alpha:	
	beq	$s0, $a1, end_print_alpha				# if (i == size_alpha) goto end_print_alpha
	move	$t0, $s1						# &alphabete
	lb	$t0, ($t0)						# *alphabete
	addi	$t0, $t0, -32
	move	$a0, $t0						# .
	print_char_							# print_char_
	print_white_space_
	addi	$s1, $s1, 1						# allphabete + 1byte
	addi	$s0, $s0, 1						# i++
	j	begin_print_alpha
end_print_alpha:
	insert_new_line_
	lw	$s1, 4($sp)
	lw	$s0, ($sp)
	add	$sp, $sp, 8
	jr	$ra

	
# Func to allocate memory for alphabet (alphabet_size)	
allocate_memory_alphabet:
	# $a0 already has columns_size
	li	$v0, 9							# syscall for malloc
	syscall
	jr	$ra