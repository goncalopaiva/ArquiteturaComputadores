#----------MACROS----------#
.macro exit_
li	$v0, 10
syscall
.end_macro

.macro print_correct_code_msg_
li	$v0, 4
la	$a0, correct_code_msg
syscall
add	$t0, $zero, $zero
move	$t1, $a1
start_macro_correct_code:
beq	$t0, 4, end_macro_correct_code
li	$v0, 11
lb	$a0, ($t1)
syscall
addi	$t1, $t1, 1
addi	$t0, $t0, 1
j	start_macro_correct_code
end_macro_correct_code:
.end_macro

.macro insert_new_line_
li	$v0, 4
la	$a0, insert_new_line
syscall
.end_macro

.macro read_char_
li	$v0, 12
syscall
.end_macro

.macro print_continue_or_exit_msg_
li	$v0, 4
la	$a0, print_continue_msg
syscall
li	$v0, 4
la	$a0, print_exit_msg
syscall
.end_macro

#----------DATA------------#
	.data
points:	.space 4	

#-----------PRINTS---------#

correct_code_msg: .asciiz "Code to be cracked: "
insert_new_line: .asciiz "\n"
print_continue_msg: .asciiz "(C)ontinue\n"
print_exit_msg: .asciiz "(E)xit\n"
	.align 2

#-----------TEXT-----------#
	.text
	.globl main
main:
	insert_new_line_
	jal	ask_user_for_board_size					
	add	$sp, $sp, -16
	sw	$v1, 0($sp)						# board lines
	sw	$v0, 4($sp)						# board columns
	
	move	$a0, $v1
	move	$a1, $v0
	jal	set_board_size						# set_board_size (lines, columns)	
	la	$s0, ($v0)						# &board
	
	jal	set_alphabet
	sw	$v0, 8($sp)						# size of alphabet
	la	$s1, ($v1)						# &alphabet
	
	la	$s2, points						# &points
				
start:
	insert_new_line_
	lw	$a0, 4($sp)						# .
	move	$a1, $s1						# ..
	lw	$a2, 8($sp)						# ...
	jal	codemaker_combination					# codemaker_combination (board_columns, &alphabet, alphabet_size)
	la	$s3, ($v0)						# &codemaker_input				
	
	lw	$a0, 4($sp)
	jal	allocate_codebreaker_input				# allocate_codebreaker_input (board columns)
	la	$s4, ($v0)						# &codebreaker_input
	
	li 	$s5, 1							# round = 1
	li	$s6, 0							# num_colors_correct = 0
	li 	$s7, 0							# num_pos_correct = 0 
	
begin_match:
	
	sw	$s0, 12($sp)						# saves &board
	
	lw	$s0, 0($sp)						# board_lines
	bgt	$s5, $s0, match_over					# if (round > board_lines) goto match_over
	lw	$s0, 12($sp)						# redo &board
	
	move	$a0, $s4		
	lw	$a1, 4($sp)
	move	$a2, $s1
	lw	$a3, 8($sp)
	jal	codebreaker_combination					# codebreaker_combination (codebreaker_input,
									#			   board_rows,
									#			   alphabete, 
									#			   alphabete_size)
	
	move	$a0, $s0
	lw	$a1, 4($sp)
	move	$a2, $s4
	move	$a3, $s5
	jal	insert_combination_on_board				# insert_combination_on_board (&board,
									# 			       board_columns,
									#			       &codemaker_input,
									#				round)
	
	move	$a0, $s4
	move	$a1, $s3
	lw	$a2, 4($sp)
	jal	check_codebreaker_combination				# check_codebreaker_comb (&codebreaker_input, &codemaker_input, board_columns)
	move	$s6, $v0						# return value of num_colors_correct
	move	$s7, $v1						# return value of num_pos_correct
	
	move	$a0, $s0		
	move	$a1, $s5 
	lw	$a2, 4($sp)
	jal	view_board						# view_board (board, round, board_columns)
	
	move	$a0, $s6						# .
	move	$a1, $s7					 	# ..
	jal	print_colors						# print_colors (num_colors_correct, num_pos_correct)
	
	lw	$t0, 4($sp)
	beq	$s7, $t0, match_over					# if (num_pos_correct == board_cols) goto match_over
	#beq	$s6, $t0, num_colors_is_correct				# .
#num_colors_is_correct:							# ..
	#beq	$s2, $t0, match_over					# if (num_colors_correct == board_cols && num_positions_correct == board_cols) goto match_over
	
	addi	$s5, $s5, 1						# round += 1
	j	begin_match
match_over:
	lw	$s0, 12($sp)						# redo &board
	 
	move	$a1, $s3
	print_correct_code_msg_						# codemaker_input
	insert_new_line_
	move	$a0, $s7						# .
	move	$a1, $s2						# ..
	lw	$a2, 4($sp)						# ...
	jal	give_player_points					# give_player_points (num_pos_correct, points, board_columns)
	
	move	$a0, $s0						# .
	lw	$a1, 0($sp)						# ..
	jal	reset_board						# reset_board (&board, board_lines, board_columns)	
									
									
###							
	move	$a0, $s2						
	jal	print_points						# print_points (points)
	
	addi	$sp, $sp, 16						# restore stack 
	
	print_continue_or_exit_msg_
	read_char_
	beq	$v0, 99, main						# if (getchar() == 'c') goto main
	beq	$v0, 101, end						# if (getchar() == 'e') goto end 

end:
	exit_
	
#-----------FUNCTIONS---------#


# Func to free memory (&address_to_free, size)
free:	
	add	$sp, $sp, -4
	sw	$s0, ($sp)
	
	li	$t0, 0		
	li	$s0, 0						# i = 0
begin:
	beq	$s0, $a1, end_one
	sw	$t0, ($s0)					# free memory
	addi	$s0, $s0, 1					# i ++
end_one:
	lw	$s0, ($sp)
	add	$sp, $sp, 4
	jr 	$ra
