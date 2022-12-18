#include <stdio.h>
#include <stdbool.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define mastermind_rows 4
#define mastermind_lines 10
#define available_colors_size 7
#define code_input_size 5

/**
 * creates codemakers combination
 * @param available_colors available colors to choose from
 * @param codemaker_input codemakers input
 * @param input_size array size
 */
void codemaker_combination(const char* available_colors, char *codemaker_input, int input_size);

/**
 * inserts codebreakers' combination
 * @param available_colors available colors to choose from
 * @param codemakers_input codemakers
 * @return
 */
void codebreaker_combination (const char *available_colors, char *codebreaker_input);

/**
 * checks if codebreakers combination is valid
 * @param codebreaker_input codebreakers combination
 * @param available_colors available colors to choose from
 * @return 1 if not valid | 0 if valid
 */
int is_codebreaker_combination_valid(char *codebreaker_input, const char *available_colors);

/**
 * inserts codebreakers' input on board
 * @param board masterminds' board
 * @param codebreaker_input codebreakers' input
 * @param round round of game
 */
void insert_codebreaker_combination_on_board(char board[][mastermind_rows], const char *codebreaker_input, const int *round);

/**
 * compares codemakers input to codebreakers input
 * @param codebreaker_input codebreakers input
 * @param codemakers_input codemakers input
 * @param num_colors number of correct colors
 * @param num_pos num of color positions correct
 */
void check_codebreaker_combination(char *codebreaker_input, char *codemakers_input, int *num_colors, int *num_pos);

/**
 * starts a new mastermind match
 * @param available_colors available colors to choose from
 * @param codemakers_input codemakers combination
 * @param points points of player
 */
void start_match(char board[][mastermind_rows], const char *available_colors, const char *codemakers_input, uint32_t *points);

/**
 * points are given to player based on his performance of match
 * @param round round of masterminds' match
 * @param points points of player
 */
void give_player_points (const int* round, const int*, uint32_t *points);

/**
 * prints points of player
 * @param points points
 */
void print_points (const uint32_t *points);

/**
 * prints current mastermind table
 * @param board masterminds' table
 * @param round round of game
 * @param num_colors number of correct colors
 * @param num_pos num of color positions correct
 */
void view_board(char board[][mastermind_rows], const int *round, const int *num_colors, const int *num_pos);

/**
 * resets board
 * @param board masterminds board
 */
void reset_board (char board[][mastermind_rows]);

//Fim de partida
int fimPartida();

//Inserir combinação no tabuleiro e efetuar verificação
void insertCombinacao (const char *input);

void viewPoints();

int main();

