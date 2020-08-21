

#include <stdio.h>
#include "Solver.h"
#include <cmath>
#define UNASSIGNED 0
#define BOARDSIZE 9


int board[9][9];
bool isQuadrantValid(int row, int col, int value);

bool isValid(int row, int col, int value)
{
    for(int currentRow{0}; currentRow < BOARDSIZE; currentRow++)
    {
        if(currentRow == row)
            continue;
        if(board[currentRow][col] == value)
        {
            return false;
        }
        
    }
    for(int currentCol{0}; currentCol < BOARDSIZE; currentCol++)
    {
        if(currentCol == col)
            continue;
        if(board[row][currentCol] == value)
        {
            return false;
        }
    }
    return true && isQuadrantValid(row, col, value);
}

bool findUnassignedPoint(int &row, int &col)
{
    for(int i{0}; i < BOARDSIZE ;  i++ )
    {
        for(int j{0}; j < BOARDSIZE; j++)
        {
            if(board[i][j] == UNASSIGNED)
            {
                row = i;
                col = j;
                return true;
            }
        }
    }
    return false;
}

bool solve()
{
    int row;
    int col;
    if(!findUnassignedPoint(row, col))
    {
        return true;
    }
    for(int i{1}; i <= BOARDSIZE; i++)
    {
        if(isValid(row, col, i))
        {
            board[row][col] = i;
            
            if (solve()) {
                return true;
            }
            board[row][col] = UNASSIGNED;
        }
    }
        return false;
}

bool isQuadrantValid(int row, int col, int value)
{
    int vIndex = ceil(double(row+1)/3);//3
    int hIndex = ceil(double(col+1)/3);//1
    
    int startRow = (vIndex - 1)*3;//6 upper left quadrant
    int startCol = (hIndex - 1)*3;//0
    
    for(int i{startRow} ; i < startRow + 3; i++)
    {
        for(int j{startCol}; j < startCol + 3; j++)
        {
            if(i == row && j == col)
            {
                continue;
            }
            if(board[i][j] == value)
            {
                return false;
            }
            
        }
    }
    return true;
}

ValuePoint* solve(const ValuePoint* points, int length)
{
    for(int i{0}; i < BOARDSIZE ;  i++ )
    {
        for(int j{0}; j < BOARDSIZE; j++)
        {
            board[i][j] = UNASSIGNED;
        }
    }
    
    for(int i{0}; i < length; i++)
    {
        ValuePoint currentValuePoint = points[i];
        board[currentValuePoint.row][currentValuePoint.column] = currentValuePoint.value;
    }
    
    solve();
    
    static ValuePoint result[BOARDSIZE * BOARDSIZE] = {};
    int currentIndex = 0;
    
    for(int i{0}; i < BOARDSIZE ;  i++ )
    {
        for(int j{0}; j < BOARDSIZE; j++)
        {
            ValuePoint currentValuePoint{i, j, board[i][j]};
            result[currentIndex] = currentValuePoint;
            currentIndex++;
        }
    }
    return result;
}
