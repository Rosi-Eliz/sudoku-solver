# Sudoku solver
An iOS application, capable of scanning and subsequently solving any Sudoku problem
## Overview
The application uses Apple's [VisionKit](https://developer.apple.com/documentation/visionkit) for performing the image recognition and the numbers scanning in conjunction with custom positioning logic. The module, responsible for solving the scanned Sudoku, is written in C++, which is plugged into the application via the SudokuSolver-Bridging-Header.h bridging header.
### Solving Algorithm
 The project uses a classic algorithm for solving the Sudoku problems. It represents a tree-based search algorithm based on backtracking, which is applied until a solution is
found. If incorrect input data is provided (e.g. multiple repeating values) no solution will be found and the empty boxes will remain unchanged.
## Demonstration
![](demo.gif)
