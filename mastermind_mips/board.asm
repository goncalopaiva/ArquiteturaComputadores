.macro print_board_size_msg_
li	$v0, 4
la	$a0, board_size_msg
syscall
.end_macro

.macro read_int_
li	$v0, 5
syscall
.end_macro

.macro insert_new_line_
li	$v0, 4
la	$a0, insert_new_line
syscall
.end_macro

.macro print_board_round_separation_
li	$v0, 4
la	$a0, round_separation
syscall
.end_macro

.macro print_char_
li	$v0, 11
syscall
.end_macro

#----------DATA------------#
	.data	
board_size_msg: .asciiz "Enter board size (lines) (columns):\n"
insert_new_line: .asciiz "\n"
round_separation: .asciiz "|"
	.align 2
#----------TEXT------------#
	.text
	
.globl ask_user_for_board_size	# Func to ask user for board size
ask_user_for_board_size:
	print_board_size_msg_
	read_int_
	move	$v1, $v0						
	read_int_							
	# v1 --> lines of board
	# v0 --> columns of board	
	jr 	$ra	
	
	
.globl set_board_size 	# Func to set initial board size (lines, columns)
set_board_size:
	mul	$t0, $a0, $a1						# calculate amount of memory needed for board
	move	$a0, $t0						# set $a0 to size to be allocated
	li	$v0, 9							# syscall for malloc
	syscall
	jr 	$ra
	
	
.globl insert_combination_on_board  # Func to insert combination on board (&board, board_rows, codebreaker_input, round)
insert_combination_on_board:
	add	$sp, $sp, -4
	sw	$s0, 0($sp)

	add 	$s0, $zero, $zero					# i = 0
	addi	$t1, $a3, -1						# round = round - 1
	mul	$t1, $t1, $a1 						# round *= board_rows
	add 	$a0, $a0, $t1						# board = board + round
insert_board_start:
	bge 	$s0, $a1, insert_board_end				# if (i >= board_columns) goto end
	move 	$t0, $a2						# codebreaker_input
	add 	$t0, $t0, $s0						# codebreaker_input + i
	lb	$t0, 0($t0)						# codebreaker_input [i]
	sb 	$t0, 0($a0)						# board[i] = codebreaker_input[i]
	addi	$a0, $a0, 1 						# board + 1
	addi	$s0, $s0, 1 						# i ++
	j 	insert_board_start
insert_board_end:
	lw	$s0, 0($sp)
	add 	$sp, $sp, 4
	jr	$ra
	

.globl view_board  # Func to display board by round (board, round, board_columns)
view_board:
	add	$sp, $sp, -12
	sw	$s0, 0($sp)
	sw	$s1, 4($sp)
	sw	$s2, 8($sp)
	
	
	add	$s0, $zero, $zero					# i = 0
	add	$s1, $zero, $zero					# j = 0
	move	$s2, $a0						# board
	
	insert_new_line_
print_lines_start:
	bge	$s0, $a1, print_lines_end				# if (i >= round) goto print_lines_end
	mul	$t0, $s0, $a2						# i * board_columns
	add	$t0, $s2, $t0						# board + i
	insert_new_line_
	print_board_round_separation_
	print_rows_start:
		bge	$s1, $a2, print_rows_end				# if (j >= 4) goto print_rows_end
		move	$t1, $t0
		lb	$t1, 0($t1)					# board [i][j]
		
		move	$a0, $t1
		print_char_
		
		addi	$t0, $t0, 1					# board + i + 1
		addi	$s1, $s1, 1					# j ++
		j	print_rows_start
	print_rows_end:
	li	$s1, 0							# j = 0
	addi	$s0, $s0, 1						# i ++
	print_board_round_separation_
	insert_new_line_
	j	print_lines_start
print_lines_end:
	
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	add	$sp, $sp, 12
	jr	$ra
	
	
.globl reset_board  # Func to memset board to 0 (&board, board_lines)
reset_board:
	add	$sp, $sp, -4
	sw	$s0, 0($sp)
	
	move	$t0, $a0						# &board
	add	$s0, $zero, $zero					# i = 0
start_reset_board:
	bge	$s0, $a1, end_reset_board
	li	$t1, 0							
	sw	$t1, ($t0)						# *board = 0
	addi	$t0, $t0, 4						# board + 4
	addi	$s0, $s0, 1						# i ++
	j	start_reset_board
end_reset_board:
	lw	$s0, 0($sp)
	add	$sp, $sp, 4
	jr	$ra
