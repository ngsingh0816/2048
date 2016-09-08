#include "game.h"
#include <string.h>

/*
 This program is fun and simple game where you combine blocks
 to get to the number 2048. You can move the blocks by pressing 
 w, a, s, and d, but be wary because one move makes all the blocks
 move as much as they can. If you slide one block into another,
 they combine and add their values together. You can create a game
 with any row and column size. The game also automatically checks
 if you lose and have no available moves left. See if you can 
 increase your score and become the 2048 legend! The moves are
 implemented by first combining all blocks that will combine
 and then sliding everything to its proper place. A single
 block cannot be combined more than one per turn.
 */


std::vector<Coord> combineCoords;

game * make_game(int rows, int cols)
/*! Create an instance of a game structure with the given number of rows
    and columns, initializing elements to -1 and return a pointer
    to it. (See game.h for the specification for the game data structure) 
    The needed memory should be dynamically allocated with the malloc family
    of functions.
*/
{
	// Create a new instance
	game* tmp = (game*)malloc(sizeof(game));
	// If we can't, indicate failure
	if (!tmp)
		return NULL;
	
	// Assign variables
	tmp->score = 0;
	tmp->cols = cols;
	tmp->rows = rows;
	// Initialize memory to the cells
	tmp->cells = (cell*)malloc(sizeof(cell) * cols * rows);
	// If we can't, indicate failure
	if (!tmp->cells)
	{
		free(tmp);
		return NULL;
	}
	// Set each cell to -1
	for (int z = 0; z < cols * rows; z++)
		tmp->cells[z] = -1;
	
	// Return this new game
	return tmp;
}



void destroy_game(game * cur_game)
/*! Deallocate any memory acquired with malloc associated with the given game instance.
    This includes any substructures the game data structure contains. */
{
	// Deallocate the memory
	free(cur_game->cells);
	free(cur_game);
}

cell * get_cell(game * cur_game, int row, int col)
/*! Given a game, a row, and a column, return a pointer to the corresponding
    cell on the game. (See game.h for game data structure specification)
    This function should be handy for accessing game cells. Return NULL
	if the row and col coordinates do not exist.
*/
{
	// Check if this is within the bounds and return NULL if its not
	if (row < 0 || row >= cur_game->rows || col	< 0 || col >= cur_game->cols || !cur_game->cells)
		return NULL;
	return &cur_game->cells[row * cur_game->cols + col];
}

int move_w(game * cur_game)
/*!Slides all of the tiles in cur_game upwards. If a tile matches with the 
   one above it, the tiles are merged by adding their values together. When
   tiles merge, increase the score by the value of the new tile. A tile can 
   not merge twice in one turn. If sliding the tiles up does not cause any 
   cell to change value, w is an invalid move and return 0. Otherwise, return 1. 
*/
{
	// Some variables
	bool value_changed = false;
	int rows = cur_game->rows;
	int cols = cur_game->cols;
	cell* cells = cur_game->cells;
	bool merged[rows * cols];
	memset(merged, 0, sizeof(bool) * rows * cols);
	
	// First go through all the cells to see if there is a match with
	// the first one directly above it
	
	// Row can start at 1 because there is nothing above the 1st row
	for (int row = 1; row < rows; row++)
	{
		for (int col = 0; col < cols; col++)
		{
			cell targetCell = cells[row * cols + col];
			// Don't need to test anything if it's empty or if its
			// already been merged
			if (targetCell == -1 || merged[row * cols + col])
				continue;
			// Find the first non empty cell above the current one
			int targetAddress = (row - 1) * cols + col;
			while (targetAddress >= 0 && cells[targetAddress] == -1)
				targetAddress -= cols;
			// Check if they are the same and that it hasnt been merged before
			if (targetAddress >= 0 && cells[targetAddress] == targetCell && !merged[targetAddress])
			{
				// Merge the two
				cells[targetAddress] *= 2;
				merged[targetAddress] = true;
				Coord cord = { targetAddress % cols, targetAddress / cols };
				combineCoords.push_back(cord);
				// Increase the score
				cur_game->score += cells[targetAddress];
				// Clear the current cell
				cells[row * cols + col] = -1;
				
				// Something has changed
				value_changed = true;
			}
		}
	}
	
	// Now move everything up (go top to bottom so everything gets move correctly)
	// Row can start at 1 because there is nothing above the 1st row
	for (int row = 1; row < rows; row++)
	{
		for (int col = 0; col < cols; col++)
		{
			cell targetCell = cells[row * cols + col];
			// Don't worry about empty cells
			if (targetCell == -1)
				continue;
			
			// Find the first non empty cell above the current one
			int targetAddress = (row - 1) * cols + col;
			while (targetAddress >= 0 && cells[targetAddress] == -1)
				targetAddress -= cols;
			// Put it down one row
			targetAddress += cols;
			// If this block doesn't move, skip it
			if (targetAddress == row * cols + col)
				continue;
			
			// This block moves so its a valid move
			value_changed = true;
			// Clear this cell
			cells[row * cols + col] = -1;
			// Move the old cell to this new location
			cells[targetAddress] = targetCell;
		}
	}
	
	// Return if something changed
    return value_changed;
};

int move_s(game * cur_game) //slide down
{
	// Some variables
	bool value_changed = false;
	int rows = cur_game->rows;
	int cols = cur_game->cols;
	cell* cells = cur_game->cells;
	bool merged[rows * cols];
	memset(merged, 0, sizeof(bool) * rows * cols);
	
	// First go through all the cells to see if there is a match with
	// the first one directly below it
	
	// No need to check the bottom row
	for (int row = 0; row < rows - 1; row++)
	{
		for (int col = 0; col < cols; col++)
		{
			cell targetCell = cells[row * cols + col];
			// Don't need to test anything if it's empty or if its
			// already been merged
			if (targetCell == -1 || merged[row * cols + col])
				continue;
			// Find the first non empty cell below the current one
			int targetAddress = (row + 1) * cols + col;
			while (targetAddress < rows * cols && cells[targetAddress] == -1)
				targetAddress += cols;
			// Check if they are the same and that it hasnt been merged before
			if (targetAddress < rows * cols && cells[targetAddress] == targetCell && !merged[targetAddress])
			{
				// Merge the two
				cells[targetAddress] *= 2;
				merged[targetAddress] = true;
				Coord cord = { targetAddress % cols, targetAddress / cols };
				combineCoords.push_back(cord);
				// Increase the score
				cur_game->score += cells[targetAddress];
				// Clear the current cell
				cells[row * cols + col] = -1;
				
				// Something has changed
				value_changed = true;
			}
		}
	}
	
	// Now move everything down (go bottom to top so everything gets move correctly)
	for (int row = rows - 2; row >= 0; row--)
	{
		for (int col = 0; col < cols; col++)
		{
			cell targetCell = cells[row * cols + col];
			// Don't worry about empty cells
			if (targetCell == -1)
				continue;
			
			// Find the first non empty cell below the current one
			int targetAddress = (row + 1) * cols + col;
			while (targetAddress < rows * cols && cells[targetAddress] == -1)
				targetAddress += cols;
			// Put it up one row
			targetAddress -= cols;
			// If this block doesn't move, skip it
			if (targetAddress == row * cols + col)
				continue;
			
			// This block moves so its a valid move
			value_changed = true;
			// Clear this cell
			cells[row * cols + col] = -1;
			// Move the old cell to this new location
			cells[targetAddress] = targetCell;
		}
	}
	
	// Return if something changed
	return value_changed;
};

int move_a(game * cur_game) //slide left
{
	// Some variables
	bool value_changed = false;
	int rows = cur_game->rows;
	int cols = cur_game->cols;
	cell* cells = cur_game->cells;
	bool merged[rows * cols];
	memset(merged, 0, sizeof(bool) * rows * cols);
	
	// First go through all the cells to see if there is a match with
	// the first one directly to the left of it
	
	// No need to check the left column
	for (int col = 1; col < cols; col++)
	{
		for (int row = 0; row < rows; row++)
		{
			cell targetCell = cells[row * cols + col];
			// Don't need to test anything if it's empty or if its
			// already been merged
			if (targetCell == -1 || merged[row * cols + col])
				continue;
			// Find the first non empty cell to the left of the current one
			int targetAddress = row * cols + col - 1;
			while (targetAddress >= row * cols && cells[targetAddress] == -1)
				targetAddress--;
			// Check if they are the same and that it hasnt been merged before
			if (targetAddress >= row * cols && cells[targetAddress] == targetCell && !merged[targetAddress])
			{
				// Merge the two
				cells[targetAddress] *= 2;
				merged[targetAddress] = true;
				Coord cord = { targetAddress % cols, targetAddress / cols };
				combineCoords.push_back(cord);
				// Increase the score
				cur_game->score += cells[targetAddress];
				// Clear the current cell
				cells[row * cols + col] = -1;
				
				// Something has changed
				value_changed = true;
			}
		}
	}
	
	// Now move everything to the left (go left to right so everything gets move correctly)
	for (int col = 1; col < cols; col++)
	{
		for (int row = 0; row < rows; row++)
		{
			cell targetCell = cells[row * cols + col];
			// Don't worry about empty cells
			if (targetCell == -1)
				continue;
			
			// Find the first non empty cell to the left of the current one
			int targetAddress = row * cols + col - 1;
			while (targetAddress >= row * cols && cells[targetAddress] == -1)
				targetAddress--;
			// Put it right one cell
			targetAddress++;
			// If this block doesn't move, skip it
			if (targetAddress == row * cols + col)
				continue;
			
			// This block moves so its a valid move
			value_changed = true;
			// Clear this cell
			cells[row * cols + col] = -1;
			// Move the old cell to this new location
			cells[targetAddress] = targetCell;
		}
	}
	
	// Return if something changed
	return value_changed;
};

int move_d(game * cur_game){ //slide to the right
	
	// Some variables
	bool value_changed = false;
	int rows = cur_game->rows;
	int cols = cur_game->cols;
	cell* cells = cur_game->cells;
	bool merged[rows * cols];
	memset(merged, 0, sizeof(bool) * rows * cols);
	
	// First go through all the cells to see if there is a match with
	// the first one directly to the right of it
	
	// No need to check the right column
	for (int col = 0; col < cols - 1; col++)
	{
		for (int row = 0; row < rows; row++)
		{
			cell targetCell = cells[row * cols + col];
			// Don't need to test anything if it's empty or if its
			// already been merged
			if (targetCell == -1 || merged[row * cols + col])
				continue;
			// Find the first non empty cell to the left of the current one
			int targetAddress = row * cols + col + 1;
			while (targetAddress < (row + 1) * cols && cells[targetAddress] == -1)
				targetAddress++;
			// Check if they are the same and that it hasnt been merged before
			if (targetAddress < (row + 1) * cols && cells[targetAddress] == targetCell && !merged[targetAddress])
			{
				// Merge the two
				cells[targetAddress] *= 2;
				merged[targetAddress] = true;
				Coord cord = { targetAddress % cols, targetAddress / cols };
				combineCoords.push_back(cord);
				// Increase the score
				cur_game->score += cells[targetAddress];
				// Clear the current cell
				cells[row * cols + col] = -1;
				
				// Something has changed
				value_changed = true;
			}
		}
	}
	
	// Now move everything to the right (go right to left so everything gets move correctly)
	for (int col = cols - 2; col >= 0; col--)
	{
		for (int row = 0; row < rows; row++)
		{
			cell targetCell = cells[row * cols + col];
			// Don't worry about empty cells
			if (targetCell == -1)
				continue;
			
			// Find the first non empty cell to the left of the current one
			int targetAddress = row * cols + col + 1;
			while (targetAddress < (row + 1) * cols && cells[targetAddress] == -1)
				targetAddress++;
			// Put it left one cell
			targetAddress--;
			// If this block doesn't move, skip it
			if (targetAddress == row * cols + col)
				continue;
			
			// This block moves so its a valid move
			value_changed = true;
			// Clear this cell
			cells[row * cols + col] = -1;
			// Move the old cell to this new location
			cells[targetAddress] = targetCell;
		}
	}
	
	// Return if something changed
	return value_changed;
};

int legal_move_check(game * cur_game)
/*! Given the current game check if there are any legal moves on the board. There are
    no legal moves if sliding in any direction will not cause the game to change.
	Return 1 if there are possible legal moves, 0 if there are none.
 */
{
	// Basically for the game to be over, the board needs to be full and
	// nothing can be touching a tile with the same value (otherwise
	// you could swipe that way)
	
	int rows = cur_game->rows;
	int cols = cur_game->cols;
	cell* cells = cur_game->cells;
	
	// Loop through the cells
	for (int row = 0; row < rows; row++)
	{
		for (int col = 0; col < cols; col++)
		{
			// Get this cell's value
			cell targetCell = cells[row * cols + col];
			// If this is empty, there is a legal move
			if (targetCell == -1)
				return 1;
			// Check to the top and if it's equal to the current cell,
			// then theres a move
			if (row != 0 && cells[(row - 1) * cols + col] == targetCell)
				return 1;
			// Same to bottom
			if (row != rows - 1 && cells[(row + 1) * cols + col] == targetCell)
				return 1;
			// Same to the left
			if (col != 0 && cells[row * cols + col - 1] == targetCell)
				return 1;
			// Same to the right
			if (col != cols - 1 && cells[row * cols + col + 1] == targetCell)
				return 1;
		}
	}
	
	// No legal moves were found
    return 0;
}


void remake_game(game ** _cur_game_ptr,int new_rows,int new_cols)
/*! Given a game structure that is passed by reference, change the
	game structure to have the given number of rows and columns. Initialize
	the score and all elements in the cells to zero. Make sure that any 
	memory previously allocated is not lost in this function.	
*/
{
	// Destory the previous game
	destroy_game(*_cur_game_ptr);
	// Create a new game
	*_cur_game_ptr = make_game(new_rows, new_cols);
}

/*! code below is provided and should not be changed */

void rand_new_tile(game * cur_game)
/*! insert a new tile into a random empty cell. First call rand()%(rows*cols) to get a random value between 0 and (rows*cols)-1.
*/
{
	
	cell * cell_ptr;
    cell_ptr = 	cur_game->cells;
	
    if (cell_ptr == NULL){ 	
        printf("Bad Cell Pointer.\n");
        exit(0);
    }
	
	
	//check for an empty cell
	int emptycheck = 0;
	int i;
	
	for(i = 0; i < ((cur_game->rows)*(cur_game->cols)); i++){
		if ((*cell_ptr) == -1){
				emptycheck = 1;
				break;
		}		
        cell_ptr += 1;
	}
	if (emptycheck == 0){
		printf("Error: Trying to insert into no a board with no empty cell. The function rand_new_tile() should only be called after tiles have succesfully moved, meaning there should be at least 1 open spot.\n");
		exit(0);
	}
	
    int ind,row,col;
	int num;
    do{
		ind = rand()%((cur_game->rows)*(cur_game->cols));
		col = ind%(cur_game->cols);
		row = ind/cur_game->cols;
    } while ( *get_cell(cur_game, row, col) != -1);
        //*get_cell(cur_game, row, col) = 2;
	num = rand()%20;
	if(num <= 1){
		*get_cell(cur_game, row, col) = 4; // 1/10th chance
	}
	else{
		*get_cell(cur_game, row, col) = 2;// 9/10th chance
	}
}

int print_game(game * cur_game) 
{
    cell * cell_ptr;
    cell_ptr = 	cur_game->cells;

    int rows = cur_game->rows;
    int cols = cur_game->cols;
    int i,j;
	
	printf("\n\n\nscore:%d\n",cur_game->score); 
	
	
	printf("\u2554"); // topleft box char
	for(i = 0; i < cols*5;i++)
		printf("\u2550"); // top box char
	printf("\u2557\n"); //top right char 
	
	
    for(i = 0; i < rows; i++){
		printf("\u2551"); // side box char
        for(j = 0; j < cols; j++){
            if ((*cell_ptr) == -1 ) { //print asterisks
                printf(" **  "); 
            }
            else {
                switch( *cell_ptr ){ //print colored text
                    case 2:
                        printf("\x1b[1;31m%04d\x1b[0m ",(*cell_ptr));
                        break;
                    case 4:
                        printf("\x1b[1;32m%04d\x1b[0m ",(*cell_ptr));
                        break;
                    case 8:
                        printf("\x1b[1;33m%04d\x1b[0m ",(*cell_ptr));
                        break;
                    case 16:
                        printf("\x1b[1;34m%04d\x1b[0m ",(*cell_ptr));
                        break;
                    case 32:
                        printf("\x1b[1;35m%04d\x1b[0m ",(*cell_ptr));
                        break;
                    case 64:
                        printf("\x1b[1;36m%04d\x1b[0m ",(*cell_ptr));
                        break;
                    case 128:
                        printf("\x1b[31m%04d\x1b[0m ",(*cell_ptr));
                        break;
                    case 256:
                        printf("\x1b[32m%04d\x1b[0m ",(*cell_ptr));
                        break;
                    case 512:
                        printf("\x1b[33m%04d\x1b[0m ",(*cell_ptr));
                        break;
                    case 1024:
                        printf("\x1b[34m%04d\x1b[0m ",(*cell_ptr));
                        break;
                    case 2048:
                        printf("\x1b[35m%04d\x1b[0m ",(*cell_ptr));
                        break;
                    case 4096:
                        printf("\x1b[36m%04d\x1b[0m ",(*cell_ptr));
                        break;
                    case 8192:
                        printf("\x1b[31m%04d\x1b[0m ",(*cell_ptr));
                        break;
					default:
						printf("  X  ");

                }

            }
            cell_ptr++;
        }
	printf("\u2551\n"); //print right wall and newline
    }
	
	printf("\u255A"); // print bottom left char
	for(i = 0; i < cols*5;i++)
		printf("\u2550"); // bottom char
	printf("\u255D\n"); //bottom right char
	
    return 0;
}

int process_turn(const char input_char, game* cur_game) //returns 1 if legal move is possible after input is processed
{ 
	int rows,cols;
	char buf[200];
	char garbage[2];
    int move_success = 0;
	
    switch ( input_char ) {
    case 'w':
        move_success = move_w(cur_game);
        break;
    case 'a':
        move_success = move_a(cur_game);
        break;
    case 's':
        move_success = move_s(cur_game);
        break;
    case 'd':
        move_success = move_d(cur_game);
        break;
    case 'q':
        destroy_game(cur_game);
        printf("\nQuitting..\n");
        return 0;
        break;
	case 'n':
		//get row and col input for new game
		dim_prompt: printf("NEW GAME: Enter dimensions (rows columns):");
		while (NULL == fgets(buf,200,stdin)) {
			printf("\nProgram Terminated.\n");
			return 0;
		}
		
		if (2 != sscanf(buf,"%d%d%1s",&rows,&cols,garbage) ||
		rows < 0 || cols < 0){
			printf("Invalid dimensions.\n");
			goto dim_prompt;
		} 
		
		remake_game(&cur_game,rows,cols);
		
		move_success = 1;
		
    default: //any other input
        printf("Invalid Input. Valid inputs are: w, a, s, d, q, n.\n");
    }

	
	
	
    if(move_success == 1){ //if movement happened, insert new tile and print the game.
         rand_new_tile(cur_game); 
		 print_game(cur_game);
    } 

    if( legal_move_check(cur_game) == 0){  //check if the newly spawned tile results in game over.
        printf("Game Over!\n");
        return 0;
    }
    return 1;
}
