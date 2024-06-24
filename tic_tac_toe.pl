initial_board([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
]).

% board is a 3x3 matrix where initially numbered from 1 to 9, which is the possible moves.
% Display the game board (Used in each iteration)
display_board(Board) :-
    write('-------------\n'),
    display_rows(Board).

% Base case for recursion; does nothing when the list of rows is empty.
display_rows([]).
display_rows([Row|Rows]) :-
    display_row(Row),
    write('\n-------------\n'),
    display_rows(Rows).

% Base case for recursion; does nothing when the list of rows is empty.
% Like CONS and CDDR : This predicate prints each cell in the row, formatted with vertical bars |, and recursively processes the remaining cells.
display_row([]).
display_row([Cell|Cells]) :-
    write('| '), write(Cell), write(' '),
    display_row(Cells).

% Update the board with the player's move
update_board(Board, Move, Player, NewBoard) :-
    update_board_rows(Board, Move, Player, NewBoard).

update_board_rows([], _, _, []).
update_board_rows([Row|Rows], Move, Player, [NewRow|NewRows]) :-
    update_row(Row, Move, Player, NewRow),
    update_board_rows(Rows, Move, Player, NewRows).

% CONDITION of Cell == Move
% If Cell matches Move --> NewCell = Player  else  NewCell remains the same as Cell
update_row([], _, _, []).
update_row([Cell|Cells], Move, Player, [NewCell|NewCells]) :-
    (   Cell == Move
    ->  NewCell = Player
    ;   NewCell = Cell
    ),
    update_row(Cells, Move, Player, NewCells).

% Check if the move is valid
%  it iterates through each row of the board. For each row found, this checks if Move is an element of that row. 
valid_move(Board, Move) :-
    between(1, 9, Move), % Move should be between 1 and 9
    member(Row, Board),
    member(Move, Row). % Move should be an unoccupied position

% Get user input and validate the move
% repeat: create an infinite loop until a condition is met
get_move(Board, Player, Move) :-
    repeat,
    write('Player '), write(Player), write(', enter your move (1-9): '),
    read(Move),
    (   valid_move(Board, Move)
    ->  true
    ;   write('Invalid move. Try again.\n'), fail).

% Define winning conditions
/* 
Why transpose for columns?
Matrix = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
]
TransposedMatrix = [
    [1, 4, 7],
    [2, 5, 8],
    [3, 6, 9]
]

now we can check them like ROWS


Why Reverse for diagonal?
Matrix = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
]
ReversedMatrix = [
    [7, 8, 9],
    [4, 5, 6],
    [1, 2, 3]
]

now we can check diagonal again without changing the code
*/
winning_condition(Board, Player) :-
    % Check rows
    (   member([Player, Player, Player], Board)
    % Check columns
    ;   transpose(Board, TransposedBoard),
        member([Player, Player, Player], TransposedBoard)
    % Check diagonals
    ;   diagonal(Board, Diagonal),
        Diagonal = [Player, Player, Player]
    ;   reverse(Board, ReversedBoard),
        diagonal(ReversedBoard, Diagonal),
        Diagonal = [Player, Player, Player]
    ).

% Transpose a matrix
transpose([], []).
transpose([F|Fs], Ts) :-
    transpose(F, [F|Fs], Ts).

transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
        lists_firsts_rests(Ms, Ts, Ms1),
        transpose(Rs, Ms1, Tss).

lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
    lists_firsts_rests(Rest, Fs, Oss).

% Extract diagonal elements from a matrix
diagonal(Matrix, Diagonal) :-
    diagonal(Matrix, 1, Diagonal).

% When the matrix is empty ([]), the diagonal is also an empty list ([]). This is the stopping condition for the recursion.
% Index: This keeps track of the current position within the row to pick the diagonal element.
% NTH: extracts the n-TH element of the list
diagonal([], _, []).
diagonal([Row|Rest], Index, [Elem|Diagonal]) :-
    nth1(Index, Row, Elem),
    NextIndex is Index + 1,
    diagonal(Rest, NextIndex, Diagonal).

% \+ -> not provable" operator, or negation by failure
% \+ Goal fails if Goal can be proven true. (~(F|T))
/*
Step1: This part iterates over each row of the board.
    Succeeds if the first argument is an element of the list provided as the second argument.
Step2: For each row found in the previous step, this part iterates over each cell in that row.
Step3: This part checks if the cell is a number.
*/
board_full(Board) :-
    \+ (member(Row, Board), member(Cell, Row), number(Cell)).

% Game loop with evaluation
game_loop(Board, Player) :-
    display_board(Board),
    get_move(Board, Player, Move),
    update_board(Board, Move, Player, NewBoard),
    (   winning_condition(NewBoard, Player)
    ->  display_board(NewBoard),
        format('Player ~w wins!~n', [Player]),
        halt
    ;   board_full(NewBoard)
    ->  display_board(NewBoard),
        write('The game is a draw!\n'),
        halt
    ;   next_player(Player, NextPlayer),
        game_loop(NewBoard, NextPlayer)
    ).

% This rule states that if the current player is 'X', then the next player will be 'O'.
next_player('X', 'O').
next_player('O', 'X').

% Initialization
:- initialization(main, main).

main :-
    initial_board(Board),
    game_loop(Board, 'X').
