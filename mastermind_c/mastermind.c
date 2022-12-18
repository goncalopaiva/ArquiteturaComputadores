#include "mastermind.h"

/*
 * 1 - Board made out of 4 columns and 10 lines
 * 2 - Code makers' combination
 * 3 - Check code breakers combination (combination has to be of type available colors)
 * 4 - Prints masterminds' current table
 */

//Verificacao do input do utilizador e gerar dicas de cores certas em posições certas/erradas

// Tabuleiro composto por 40 células -> 4 colunas e 10 linhas
// Cores disponíveis: 
//          B - Blue
//          G - Green
//          R - Red
//          Y - Yellow
//          W - White
//          O - Orange
// Utilizador insere a combinação da esquerda para a direita. 
// Ex.: BBWO -> Blue Blue White Orange
// Quando o jogador ganha uma partida +12 pontos
// Quando o jogador perde uma partida -3 pontos (até 0)
// Na ultima jogada +3 pontos por cada cor correta na posição correta
// Quando acaba a partida -> mostrar combinação -> limpar jogadas -> novo jogo

void codemaker_combination (const char* available_colors, char *codemakers_input, int input_size) {
    for (int i = 0; i < input_size; ++i) {
        int random_number = (rand() % (5 - 1 + 1)) + 1;
        codemakers_input[i] = available_colors[random_number];
    }

}

void codebreaker_combination (const char *available_colors, char *codebreaker_input) {

    printf("Available colors: B, G, R, Y, W, O\n");
    printf("Insert a combination: \n");
    for (int i = 0; i < code_input_size - 1; ++i) {
        scanf(" %c", codebreaker_input + i);
    }

    while (is_codebreaker_combination_valid(codebreaker_input, available_colors) != 0) {
        printf("Available colors: B, G, R, Y, W, O\n");
        printf("Insert a combination: \n");
        for (int i = 0; i < code_input_size; ++i) {
            scanf(" %c", codebreaker_input + i);
        }
    }
}

int is_codebreaker_combination_valid(char *codebreaker_input, const char *available_colors) {
    int count = 0;
    for (int i = 0; i < code_input_size - 1; ++i) {
        for (int j = 0; j < available_colors_size - 1; ++j) {
            codebreaker_input[i] = (char) toupper(codebreaker_input[i]); // needed for case sensitivity
            if (codebreaker_input[i] != available_colors[j])
                count++;
        }
        if (count == available_colors_size - 1) return 1;
        count = 0;
    }
    return 0;
}

void insert_codebreaker_combination_on_board(char board[][mastermind_rows], const char *codebreaker_input, const int *round) {

    for (int i = 0; i < code_input_size - 1; ++i) {
        board[*(round) - 1][i] = codebreaker_input[i];
    }

}

void check_codebreaker_combination(char *codebreaker_input, char *codemakers_input, int *num_colors, int *num_pos) {

    *num_colors = 0;
    *num_pos = 0;

    char temp_codemaker[4];

    for (int i = 0; i < code_input_size - 1; ++i) {
        temp_codemaker[i] = codemakers_input[i];
    }


    for (int i = 0; i < code_input_size - 1; ++i) {
        if (codebreaker_input[i] == codemakers_input[i]) {
            *num_pos += 1;
            codemakers_input[i] = ' ';
            codebreaker_input[i] = ' ';
        }
    }

    for (int i = 0; i < code_input_size - 1; ++i) {
        for (int j = 0; j < code_input_size - 1; ++j) {
            if (codemakers_input[i] == ' ') break;
            if (codemakers_input[i] == codebreaker_input[j]) {
                *num_colors += 1;
                codemakers_input[i] = ' ';
            }

        }
    }

    for (int i = 0; i < code_input_size - 1; ++i) {
        codemakers_input[i] = temp_codemaker[i];
    }

}

void give_player_points (const int *round, const int *pos_correct, uint32_t *points) {

    if (*round == 10 && *pos_correct != 4) {
        if (*points < 3) *points = 0; // points can't be negative
        else *points -= 3;
    }
    else *points += 12;

}

void view_board(char board[][mastermind_rows], const int *round, const int *num_colors, const int* num_pos) {
    printf("-------------");
    for (int i = 0; i < *round; i++) {
        printf("\n| ");
        for (int j = 0; j < code_input_size - 1; j++) {
            printf("%c ", board[i][j]);
        }
        printf("|\n");
    }

    printf("Num of correct colors on wrong positions: %d\n", *num_colors);
    printf("Num of correct color on right positions: %d\n", *num_pos);
    printf("-------------");
    printf("\n");
}

void start_match (char board[][mastermind_rows], const char *available_colors, const char *codemakers_input, uint32_t *points) {

    printf("\t  :: MASTERMIND :: \n\n");
    int round = 1;
    int num_colors_correct = 0;
    int num_positions_correct = 0;
    char codebreaker_input[code_input_size] = "";

    while (round <= 10) {
        codebreaker_combination(available_colors, codebreaker_input);
        insert_codebreaker_combination_on_board(board, codebreaker_input, &round);
        check_codebreaker_combination(codebreaker_input, codemakers_input, &num_colors_correct, &num_positions_correct);
        view_board(board, &round, &num_colors_correct, &num_positions_correct);
        if (num_colors_correct == code_input_size - 1 && num_positions_correct == code_input_size - 1) break;
        round += 1;
    }

    printf("Code to be cracked: %s\n", codemakers_input);
    give_player_points(&round, &num_positions_correct, points);
}

void reset_board (char board [][mastermind_rows]) {

    for (int i = 0; i < mastermind_lines; ++i) {
        for (int j = 0; j < mastermind_rows; ++j) {
            board[i][j] = ' ';
        }
    }

}

void print_points (const uint32_t *points) {
    printf("Points: %d\n", *points);
}

int main () {
    char board [mastermind_lines][mastermind_rows]; // Mastermind board
    char available_colors [available_colors_size] = "BGRYWO";
    char codemaker_input [code_input_size] = ""; // Codemakers' starting code combination
    uint32_t points = 0;
    mastermind:
    codemaker_combination(available_colors, codemaker_input, code_input_size - 1); // create codemaker starting code combination
    start_match(board, available_colors, codemaker_input, &points);
    print_points(&points);
    reset_board(board);
    printf("(C)ontinue\n(E)xit\n");
    if (getchar() == 'e' || getchar() == 'E')
        exit(1);
    if (getchar() == 'c' || getchar() == 'C')
        goto mastermind;
    return 0;
}

