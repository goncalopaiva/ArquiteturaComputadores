.macro print_points_msg_
li	$v0, 4
la	$a0, print_points_msg
syscall
.end_macro

.macro print_int_
li	$v0, 1
syscall
.end_macro

.macro insert_new_line_
li	$v0, 4
la	$a0, insert_new_line
syscall
.end_macro

	.data
	
print_points_msg: .asciiz "Points: "
insert_new_line: .asciiz "\n"
	
	.text
	
.globl give_player_points # Func to give player points || give_player_points (num_pos_correct, points, board_columns)
give_player_points:
	
	move	$t0, $a1						# points
	lw	$t0, ($t0)
	
	 
	beq	$a0, $a2, win						# if (num_pos_correct == 4) goto win
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
	
	
.globl print_points # Func to print player points
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