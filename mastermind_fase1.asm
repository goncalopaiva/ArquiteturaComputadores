# Vitor Santos 38132
# Gonçalo Paiva 39807
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
la	$t1, codemaker_input
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

.macro insert_new_line_
li	$v0, 4
la	$a0, insert_new_line
syscall
.end_macro

.macro print_white_space_
li	$v0, 4
la	$a0, white_space
syscall
.end_macro

.macro print_board_round_separation_
li	$v0, 4
la	$a0, round_separation
syscall
.end_macro

.macro print_points_msg_
li	$v0, 4
la	$a0, print_points_msg
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

.macro print_char_
li	$v0, 11
syscall
.end_macro

.macro print_int_
li	$v0, 1
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

.macro random_int_
addi	$a1, $zero, 6
addi	$v0, $zero, 42
syscall
.end_macro
#----------DATA------------#
	.data
board:	.space 40
colors: .ascii "bgrywo"
	.align 2
codemaker_input: .space 4	
	.align 2
codebreaker_input: .space 4
points:	.space 4
codemaker_temp: .space 4
	.align 2

#-----------PRINTS---------#
correct_code_msg: .asciiz "Code to be cracked: "
available_colors_msg: .asciiz "Available colors: B, G, R, Y, W, O\n"
insert_combination_msg: .asciiz "Insert a combination: "
num_colors_correct_msg:	.asciiz "Num of colors correct on incorrect positions: "
num_pos_correct_msg: .asciiz "Num of colors correct on positions correct: "
print_points_msg: .asciiz "Points: "
insert_new_line: .asciiz "\n"
round_separation: .asciiz "|"
white_space: .asciiz " "
print_continue_msg: .asciiz "(C)ontinue\n"
print_exit_msg: .asciiz "(E)xit\n"
	.align 2
#-----------TEXT-----------#
	.text
	.globl main
main:
	
	la	$s0, board
	la	$s1, colors
	la	$s2, codemaker_input
	la	$s3, points	
	add	$t0, $zero, $zero
	sw	$t0, ($s3)						# points = 0			
start:
	insert_new_line_
	move	$a0, $s1				
	move	$a1, $s2
	jal	codemaker_combination					# codemaker_combination (colors, codemaker_input)
	
	move	$a0, $s0
	move	$a1, $s1
	move	$a2, $s2
	move	$a3, $s3 
	jal	start_match						# starts match (board [][], colors, codemaker_input, points)
	
	move	$a0, $s3						
	jal	print_points						# print_points (points)
	
	print_continue_or_exit_msg_
	read_char_
	beq	$v0, 99, start						# if (getchar() == 'c') goto start
	beq	$v0, 101, end						# if (getchar() == 'e') goto end 

end:
	exit_
	
#-----------FUNCTIONS---------#

# Func to create codemakers input	
codemaker_combination:
	add	$sp, $sp, -12						# add to stack
	sw	$s0, 0($sp)
	sw	$a0, 4($sp)
	sw	$a1, 8($sp)

	add	$s0, $zero, $zero					# i = 0
begin_codemaker_input:
	beq	$s0, 4, codemaker_input_end				# if (i == 4) goto codemaker_input_end
	move	$t0, $a0						# $t0 = &colors
	move	$t1, $a1						# $t1 = &codemaker_input
	random_int_
	add	$t0, $t0, $a0						# $t0 = colors + random_int_
	lb	$t0, 0($t0)						# $t0 = colors [random_int_]
	add	$t1, $t1, $s0						# $t1 = codemaker_input + i
	sb	$t0, ($t1)						# codemaker_input[i] = colors(random_int_)
	addi	$s0, $s0, 1 						# i++
	lw	$a0, 4($sp)						# $a0 = &colors
	lw	$a1, 8($sp)						# $a1 = &codemaker_input
	j	begin_codemaker_input
codemaker_input_end:
	lw	$s0, 0($sp)						# restore stack
	add	$sp, $sp, 12
	jr	$ra
	

# Func to start match (board, colors, codeamaker_input, points)
start_match:
	add 	$sp, $sp, -20
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)

	addi 	$s0, $zero, 1						# round = 1
	add 	$s1, $zero, $zero					# num_colors_correct = 0
	add 	$s2, $zero, $zero					# num_pos_correct = 0 
	la	$s3, codebreaker_input
	move	$s4, $a0						# board
	move	$s5, $a1						# colors
	move	$s6, $a2						# codemaker_input
	move	$s7, $a3						# points

begin_match:
	bgt	$s0, 10, match_over					# if (round > 10) goto match_over

	move	$a0, $s3		
	move	$a1, $s5
	jal	codebreaker_combination					# codebreaker_combination (codebreaker_input, colors)
	
	move	$a0, $s4
	move	$a1, $s3
	move	$a2, $s0
	jal	insert_combination_on_board				# insert_combination_on_board (board [][], codebreaker_input, round)
	
	move	$a0, $s3
	move	$a1, $s6
	jal	check_codebreaker_combination				# check_codebreaker_comb (codebreaker_input, codemaker_input)
	move	$s1, $v0						# return value of num_colors_correct
	move	$s2, $v1						# return value of num_pos_correct
	
	move	$a0, $s4			
	move	$a1, $s0
	move	$a2, $s1
	move	$a3, $s2
	jal	view_board						# view_board (board[][], round, num_colors_corr, num_pos_corr)
	
	beq	$s1, 4, num_colors_is_correct				# .
num_colors_is_correct:							# ..
	beq	$s2, 4, match_over					# if (num_colors_correct == 4 && num_positions_correct == 4) goto match_over
	
	addi	$s0, $s0, 1						# round += 1
	j	begin_match
match_over:

	print_correct_code_msg_						# codemaker_input
	insert_new_line_
	move	$a0, $s2						# .
	move	$a1, $s7						# ..
	jal	give_player_points					# give_player_points (num_pos_correct, points)
	
	move	$a0, $s4
	jal	reset_board
	
	lw	$ra, 0($sp)	
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	add 	$sp, $sp, 20
	jr	$ra

# Func to create codebreaker_input
codebreaker_combination:
	add 	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)						# &codebreaker_input
	sw	$s0, 8($sp)	
	move	$t0, $a0
	insert_new_line_
	print_available_colors_msg_
	print_insert_combination_msg_
	lw	$t0, 4($sp)						# redo &codebreaker_input
	add 	$s0, $zero, $zero					# i = 0
start_insert_comb:
	bge	$s0, 4, end_insert_comb					# if (i == 4) goto end_insert_comb
	read_char_
	sb 	$v0, ($t0)						# codebreaker [i] = read_char_
	addi	$t0, $t0, 1						# codebreaker + 1byte
	addi 	$s0, $s0, 1						# i ++
	j 	start_insert_comb
end_insert_comb:
	lw	$a0, 4($sp)
	jal	is_codebreaker_combination_valid			# is_codebreaker_combination_valid (codebreaker_input, colors)
	beq	$v0, 0, codebreaker_combination				# if (is_codebreaker_combination_valid == 0) goto codebreaker_combination
	
	lw	$ra, 0($sp)
	lw	$a0, 4($sp)	
	lw	$s0, 8($sp)	
	add 	$sp, $sp, 12
	jr	$ra

# Func to check is codebreaker combination is valid
is_codebreaker_combination_valid:
	add 	$sp, $sp, -12
	sw	$s0, 0($sp)
	sw	$s1, 4($sp)
	sw	$s2, 8($sp)

	add 	$s0, $zero, $zero					# count = 0
	add 	$s1, $zero, $zero					# i = 0
	add 	$s2, $zero, $zero					# j = 0
check_codebreaker_input_loop:
	bge 	$s1, 4, check_codebreaker_input_loop_end
	check_available_colors_input_loop:
		bge 	$s2, 6, check_available_colors_input_loop_end
			move 	$t0, $a0				# &codebreaker_input
			add 	$t0, $t0, $s1				# codebreaker_input + i
			lb	$t0, 0($t0)				# codebreaker_input [i]
			move 	$t1, $a1				# &colors
			add 	$t1, $t1, $s2				# colors + j
			lb	$t1, 0($t1)				# colors [j]
			addi 	$s2, $s2, 1				# j ++
			beq	$t0, $t1, check_available_colors_input_loop	# if (codebreaker_input [i] == colors [j]) goto check..
			addi 	$s0, $s0, 1				# i ++
			j 	check_available_colors_input_loop
	check_available_colors_input_loop_end:
	bne 	$s0, 6, valid						#if (count =! 6) goto valid
	li 	$v0, 0							# else return 0
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	add	$sp, $sp, 12
	jr 	$ra
	valid:
	add 	$s0, $zero, $zero					# count = 0
	addi 	$s1, $s1, 1						# i ++
	add 	$s2, $zero, $zero					# j = 0
	j 	check_codebreaker_input_loop
check_codebreaker_input_loop_end:
	li 	$v0, 1							# return 1
	
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	add	$sp, $sp, 12
	jr	$ra

# Func to insert combination on mastermind board
insert_combination_on_board:
	add	$sp, $sp, -4
	sw	$s0, 0($sp)

	add 	$s0, $zero, $zero					# i = 0
	addi	$t1, $a2, -1						# round = round - 1
	sll	$t1, $t1, 2 						# round *= 4
	add 	$a0, $a0, $t1						# board = board + round
insert_board_start:
	bge 	$s0, 4, insert_board_end				# if (i >= 4) goto end
	move 	$t0, $a1						# codebreaker_input
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
	
	
# Func to check codebreaker_combination (nº of pos and colors correct)
check_codebreaker_combination:
	add 	$sp, $sp, -20
	sw	$s0, 0($sp)
	sw	$s1, 4($sp)
	sw	$s2, 8($sp)
	sw	$s3, 12($sp)
	sw	$s4, 16($sp)
 
	
	add 	$s0, $zero, $zero					# i = 0
	add 	$s1, $zero, $zero					# j = 0
	li 	$s2, 0							# num_colors_correct
	li 	$s3, 0							# num_pos_correct
	la	$s4, codemaker_temp					 
	
copy_codemaker_start:
	beq	$s0, 4, copy_codemaker_end
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
	bge 	$s0, 4, first_loop_end					# if (i >= 4) goto first end
	
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
	li	$t2, 32							# .
	sb	$t2, 0($t0)						# codebreaker_input [i] = ' '
	sb	$t2, 0($t1)						# codemaker_input [i] = ' '
pos_not_found:
	addi	$s0, $s0, 1 						# i ++
	j 	first_loop_start
first_loop_end:
	li	$s0, 0							# i = 0
	
second_loop_start:
	bge	$s0, 4, second_loop_end			
	
	move 	$t0, $a1						# codemaker_input
	add 	$t0, $t0, $s0						# codemaker_input + i
	lb	$t1, 0($t0)						# codemaker_input [i]	
	third_loop_start:
		bge	$s1, 4, third_loop_end
		
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
	beq	$s0, 4, redo_codemaker_end
	
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
	add 	$sp, $sp, 20
	jr	$ra
	
# Func to display board by round
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
	sll	$t0, $s0, 2						# i * 4 
	add	$t0, $s2, $t0						# board + i
	insert_new_line_
	print_board_round_separation_
	print_rows_start:
		bge	$s1, 4, print_rows_end				# if (j >= 4) goto print_rows_end
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
	
	print_correct_colors_msg_
	move	$a0, $a2
	print_int_
	
	insert_new_line_
	
	print_correct_pos_msg_
	move	$a0, $a3
	print_int_
	
	insert_new_line_
	
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	add	$sp, $sp, 12
	jr	$ra

# Func to give player points || give_player_points (num_pos_correct, points)
give_player_points:
	
	move	$t0, $a1						# points
	lw	$t0, ($t0)
	
	 
	beq	$a0, 4, win						# if (num_pos_correct == 4) goto win
	bge	$a0, 1, parcial_correct
	bge	$t0, 3, points_not_negative				# if (points > 3) goto points_not_negative
	li	$t0, 0							# *points = 0
	sw	$t0, ($a1)						# *points = 0
	jr	$ra
points_not_negative:	
	addi	$t0, $t0, -3						# *points - 3 
	sw	$t0, ($a1)						# *points -= 3
	jr	$ra
win:
	addi	$t0, $t0, 12						# *points + 12
	sw	$t0, ($a1)						# *points += 12
	jr	$ra
parcial_correct:
	mul	$t1, $a0, 3						# $t1 = num_pos_correct * 3
	add	$t0, $t0, $t1						# *points += (num_pos_correct * 3)
	sw	$t0, ($a1)
	jr	$ra
	
# Func to print player points
print_points:
	add	$sp, $sp, -4
	sw	$s0, 0($sp)
	
	move	$s0, $a0						# &points
	lw	$s0, ($s0)
	
	print_points_msg_
	
	move	$a0, $s0
	print_int_							# print points
	
	insert_new_line_
	
	lw	$s0, 0($sp)
	add	$sp, $sp, 4
	jr	$ra
	
# Func to memset board to 0 (&board)
reset_board:
	add	$sp, $sp, -4
	sw	$s0, 0($sp)
	
	move	$t0, $a0						# &board
	add	$s0, $zero, $zero					# i = 0
start_reset_board:
	bge	$s0, 10, end_reset_board
	li	$t1, 0							
	sw	$t1, ($t0)						# *board = 0
	addi	$t0, $t0, 4						# board + 4
	addi	$s0, $s0, 1						# i ++
	j	start_reset_board
end_reset_board:
	lw	$s0, 0($sp)
	add	$sp, $sp, 4
	jr	$ra
