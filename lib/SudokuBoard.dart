import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_app/SudokoProvider.dart';

class SudokuBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sudokuProvider = context.watch<SudokuProvider>();

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 9,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 81,
      itemBuilder: (context, index) {
        int row = index ~/ 9;
        int col = index % 9;
        int value = sudokuProvider.board[row][col];
        bool isWrong = sudokuProvider.wrongCells.contains(Point(row, col));

        return GestureDetector(
          onTap: () {
            if (value == 0 && sudokuProvider.lives > 0) {
              _showNumberInputDialog(context, row, col);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                    color: col % 3 == 0 ? Colors.black : Colors.grey,
                    width: col % 3 == 0 ? 2 : 1),
                top: BorderSide(
                    color: row % 3 == 0 ? Colors.black : Colors.grey,
                    width: row % 3 == 0 ? 2 : 1),
                right: BorderSide(
                    color: col % 3 == 2 ? Colors.black : Colors.transparent,
                    width: 2),
                bottom: BorderSide(
                    color: row % 3 == 2 ? Colors.black : Colors.transparent,
                    width: 2),
              ),
              color: isWrong
                  ? Colors.red.withOpacity(0.3)
                  : (value == 0 ? Colors.white : Colors.grey[300]),
            ),
            child: Center(
              child: Text(
                value == 0 ? "" : value.toString(),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isWrong ? Colors.red : Colors.black),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showNumberInputDialog(BuildContext context, int row, int col) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter a number"),
          content: Wrap(
            children: List.generate(9, (index) {
              return ElevatedButton(
                onPressed: () {
                  context
                      .read<SudokuProvider>()
                      .updateCell(row, col, index + 1);
                  Navigator.pop(context);
                },
                child: Text("${index + 1}"),
              );
            }),
          ),
        );
      },
    );
  }
}
