.macro insert_new_line_
li	$v0, 4
la	$a0, insert_new_line
syscall
.end_macro

.macro print_available_colors_msg_
li	$v0, 4
la	$a0, available_colors_msg
syscall
.end_macro

.macro print_insert_combination_msg_
li	$v0, 4
la	$a0, insert_combination_msg
syscall
.end_macro

.macro print_correct_colors_msg_
li	$v0, 4
la	$a0, num_colors_correct_msg
syscall
.end_macro

.macro print_correct_pos_msg_
li	$v0, 4
la	$a0, num_pos_correct_msg
syscall
.end_macro

.macro read_char_
li	$v0, 12
syscall
.end_macro

.macro print_int_
li	$v0, 1
syscall
.end_macro

	.data

available_colors_msg: .asciiz "Available colors:"
insert_combination_msg: .asciiz "Insert a combination: \n"	
insert_new_line: .asciiz "\n"
num_colors_correct_msg:	.asciiz "Num of colors correct on incorrect positions: "
num_pos_correct_msg: .asciiz "Num of colors correct on positions correct: "
	.align 2
	
	.text

.globl codebreaker_combination # Func to create codebreaker_input
codebreaker_combination:
	add 	$sp, $sp, -16
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)						# &codebreaker_input
	sw	$s0, 8($sp)	
	sw	$a1, 12($sp)
	move	$t0, $a0
	insert_new_line_
	print_available_colors_msg_
	move	$a0, $a2						# .
	move	$a1, $a3						# .. 
	jal	print_alphabet						# print_alphabete (&alphabete, alphabete_size)
	lw	$a0, 4($sp)						# redo $a0
	lw	$a1, 12($sp)						# redo $a1
	print_insert_combination_msg_
	lw	$t0, 4($sp)						# &codebreaker_input
	add 	$s0, $zero, $zero					# i = 0
start_insert_comb:
	bge	$s0, $a1, end_insert_comb				# if (i == board_columns) goto end_insert_comb
	read_char_
	sb 	$v0, ($t0)						# codebreaker [i] = read_char_
	addi	$t0, $t0, 1						# codebreaker + 1byte
	addi 	$s0, $s0, 1						# i ++
	j 	start_insert_comb
end_insert_comb:
	lw	$a0, 4($sp)
	jal	is_codebreaker_combination_valid			# is_codebreaker_combination_valid (codebreaker_input, board_rows, alphabete, alphabete_size)
	beq	$v0, 0, codebreaker_combination				# if (is_codebreaker_combination_valid == 0) goto codebreaker_combination
	
	lw	$ra, 0($sp)
	lw	$a0, 4($sp)	
	lw	$s0, 8($sp)	
	add 	$sp, $sp, 16
	jr	$ra
	
	
.globl check_codebreaker_combination # Func to check codebreaker_combination (&codebreaker_input, &codemaker_input, board_columns)
check_codebreaker_combination:
	add 	$sp, $sp, -28
	sw	$s0, 0($sp)
	sw	$s1, 4($sp)
	sw	$s2, 8($sp)
	sw	$s3, 12($sp)
	sw	$s4, 16($sp)
 	sw	$a0, 20($sp)
 	sw	$ra, 24($sp)
	
	add 	$s0, $zero, $zero					# i = 0
	add 	$s1, $zero, $zero					# j = 0
	li 	$s2, 0							# num_colors_correct
	li 	$s3, 0							# num_pos_correct
	
	move	$a0, $a2						# .
	jal	allocate_codemaker_temp					# allocate_codemaker_temp (board_columns)
	la	$s4, ($v0)					 
	lw	$a0, 20($sp)						# redo codebreaker_input
	
copy_codemaker_start:
	beq	$s0, $a2, copy_codemaker_end				# if (i == board_columns) goto copy_codeamker_end
	move 	$t0, $a1						# codemaker_input
	add 	$t0, $t0, $s0						# codemaker_input + i
	lb	$t0, 0($t0)						# codemaker_input [i]
	move	$t1, $s4						# codemaker_temp
	add	$t1, $t1, $s0						# codemaker_temp + i
	sb	$t0, ($t1)						# codemaker_temp[i] = codemaker_input[i]	
	addi	$s0, $s0, 1						# i ++
	j	copy_codemaker_start
copy_codemaker_end:
	li	$s0, 0							# i = 0
	
first_loop_start:
	bge 	$s0, $a2, first_loop_end				# if (i >= board_columns) goto first end
	
	move 	$t0, $a0						# codebreaker_input
	add 	$t0, $t0, $s0						# codebreaker_input + i
	lb	$t2, 0($t0)						# codebreaker_input [i]
	
	move 	$t1, $a1						# codemaker_input
	add 	$t1, $t1, $s0						# codemaker_input + i
	lb	$t3, 0($t1)						# codemaker_input [i]
	
	beq	$t2, $t3, pos_found
	bne	$t2, $t3, pos_not_found 
pos_found:
	addi	$s3, $s3, 1						# num_pos += 1
	li	$t2, 32							# ' '
	sb	$t2, 0($t0)						# codebreaker_input [i] = ' '
	sb	$t2, 0($t1)						# codemaker_input [i] = ' '
pos_not_found:
	addi	$s0, $s0, 1 						# i ++
	j 	first_loop_start
first_loop_end:
	li	$s0, 0							# i = 0
	
second_loop_start:
	bge	$s0, $a2, second_loop_end				
	
	move 	$t0, $a1						# codemaker_input
	add 	$t0, $t0, $s0						# codemaker_input + i
	lb	$t1, 0($t0)						# codemaker_input [i]	
	third_loop_start:
		bge	$s1, $a2, third_loop_end
		
		move 	$t2, $a0					# codebreaker_input
		add 	$t2, $t2, $s1					# codebreaker_input + j
		lb	$t2, 0($t2)					# codebreaker_input [j]
		
		beq	$t1, 32, third_loop_end				# if (codemaker_input [i] == ' ') break
		
		beq	$t1, $t2, color_found				# if (maker[i] == breaker[j]) goto color_found
		bne	$t1, $t2, color_not_found			# if (maker[i] != breaker[j]) goto color_not_found
		color_found:
		addi	$s2, $s2, 1					# num_colors += 1
		li	$t1, 32						# ' '
		sb	$t1, 0($t0)					# codemaker_input [i] = ' '
		color_not_found:
		addi	$s1, $s1, 1					# j ++
		j	third_loop_start
	third_loop_end:
	li	$s1, 0							# j = 0
	addi	$s0, $s0, 1						# i ++
	j	second_loop_start
second_loop_end:
	li	$s0, 0							# i = 0

redo_codemaker_start:
	beq	$s0, $a2, redo_codemaker_end
	
	move	$t0, $s4						# codemaker_temp
	add	$t0, $t0, $s0						# codemaker_temp + i
	lb	$t0, 0($t0)						# codemaker_temp [i]
	
	move 	$t1, $a1						# codemaker_input
	add 	$t1, $t1, $s0						# codemaker_input + i
	sb	$t0, 0($t1)						# codemaker_input [i] = codemaker_temp [i]
	
	addi	$s0, $s0, 1						# i ++
	j	redo_codemaker_start
redo_codemaker_end:
	
	move 	$v0, $s2						# return num_colors_correct
	move 	$v1, $s3						# return num_pos_correct
	
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$ra, 24($sp)
	add 	$sp, $sp, 28
	jr	$ra
	
	
# Func to check is codebreaker combination is valid (codebreaker_input, board_rows, alphabete, alphabete_size)
is_codebreaker_combination_valid:
	add 	$sp, $sp, -8
	sw	$s1, 0($sp)
	sw	$s2, 4($sp)

	add 	$s1, $zero, $zero					# i = 0
	add 	$s2, $zero, $zero					# j = 0

check_codebreaker_begin:	
	bge	$s1, $a1, check_codebreaker_end
	check_alpha_begin:
		bge	$s2, $a3, check_alpha_end
		
		move 	$t0, $a0				# &codebreaker_input
		add 	$t0, $t0, $s1				# codebreaker_input + i
		lb	$t0, 0($t0)				# codebreaker_input [i]
		move 	$t1, $a2				# &alphabete
		add 	$t1, $t1, $s2				# alphabete + j
		lb	$t1, 0($t1)				# alphabete [j]
		
		beq	$t0, $t1, check_alpha_end		# if (cb[i] == alpha[j]) goto check_alpha_end
		addi	$s2, $s2, 1				# j ++
		j	check_alpha_begin
		
	check_alpha_end:
		bge	$s2, $a3, not_valid			# if (j == alpha_size) goto not_valid
		addi	$s1, $s1, 1				# i ++
		li	$s2, 0					# j = 0
		j	check_codebreaker_begin
check_codebreaker_end:
	li 	$v0, 1							# return 1
	lw	$s1, 0($sp)
	lw	$s2, 4($sp)
	add	$sp, $sp, 8
	jr	$ra
not_valid: 
	li 	$v0, 0							# if not valid return 0
	lw	$s1, 0($sp)
	lw	$s2, 4($sp)
	add	$sp, $sp, 8
	jr 	$ra
	
	
	
.globl print_colors # Func to print correct colors in (in)correct positions
print_colors:
	add	$sp,  $sp, -4
	sw	$a0, 0($sp)
	
	print_correct_colors_msg_
	lw	$a0, 0($sp)						# colors correct
	print_int_
	insert_new_line_
	print_correct_pos_msg_
	move	$a0, $a1
	print_int_
	insert_new_line_
	add	$sp, $sp 4
	jr	$ra
	
	
.globl allocate_codebreaker_input # Func to allocate memory for codebreaker combination
allocate_codebreaker_input:
	li	$v0, 9
	syscall
	jr	$ra
	
# Func to allocate memory for temp_codameker_input	
allocate_codemaker_temp:
	# $a0 already has codemaker_input_size
	li	$v0, 9							# syscall for malloc
	syscall
	jr	$ra
