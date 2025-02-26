import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SudokuProvider extends ChangeNotifier {
  List<List<int>> board = List.generate(9, (_) => List.filled(9, 0));
  List<List<int>> solution = List.generate(9, (_) => List.filled(9, 0));
  final List<String> winMessages = [
    "I Love You! I am sure that you are my wife in every universe 💕",
    "You complete me, Rinky, in ways I never knew possible. Always and forever. 💍",
    "I want to die with this dream! Because I still cant believe that we are married! 🤯",
    "Amader bacchar brilliant howar possibility high 🤩",
    "Choosing BAGHC was the best decision ever! 😁",
    "In your eyes, I see my forever. I love you more every single day. 💘",
    "Inky pinky ponky, Rinky is not a donkey 😎",
  ];
  final Random _random = Random();
  List<List<List<int>>> boardHistory = []; // Stack to store board states
  List<String> winHistory = []; // List to store win history

  SudokuProvider() {
    generateSudoku();
  }

  void generateSudoku() {
    board = _generateFullBoard();
    solution = board.map((row) => List<int>.from(row)).toList();
    _removeNumbers();
    boardHistory.clear(); // Clear history when a new game starts
    notifyListeners();
  }

  String getRandomWinMessage() {
    return winMessages[_random.nextInt(winMessages.length)];
  }

  bool isGameWon() {
    return board.every((row) => row.every((cell) => cell != 0)) &&
        _isBoardCorrect();
  }

  bool _isBoardCorrect() {
    for (int i = 0; i < 9; i++) {
      Set<int> rowSet = {}, colSet = {}, boxSet = {};
      for (int j = 0; j < 9; j++) {
        if (!rowSet.add(board[i][j]) || !colSet.add(board[j][i])) return false;
        int boxRow = 3 * (i ~/ 3) + j ~/ 3;
        int boxCol = 3 * (i % 3) + j % 3;
        if (!boxSet.add(board[boxRow][boxCol])) return false;
      }
    }
    return true;
  }

  void updateCell(int row, int col, int value) {
    // Save the current state before updating
    boardHistory.add(board.map((row) => List<int>.from(row)).toList());

    board[row][col] = value;
    notifyListeners();
  }

  void undo() {
    if (boardHistory.isNotEmpty) {
      board = boardHistory.removeLast(); // Revert to the last saved state
      notifyListeners();
    }
  }

  void addWinToHistory() {
    String timestamp = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    winHistory.add("Won on: $timestamp");
    notifyListeners();
  }

  List<List<int>> _generateFullBoard() {
    List<List<int>> board = List.generate(9, (_) => List.filled(9, 0));
    _fillDiagonalBoxes(board);
    _solveBoard(board);
    return board;
  }

  void _fillDiagonalBoxes(List<List<int>> board) {
    for (int i = 0; i < 9; i += 3) {
      _fillBox(board, i, i);
    }
  }

  void _fillBox(List<List<int>> board, int row, int col) {
    Random rand = Random();
    List<int> nums = List.generate(9, (index) => index + 1)..shuffle();
    int index = 0;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        board[row + i][col + j] = nums[index++];
      }
    }
  }

  bool _solveBoard(List<List<int>> board) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          for (int num = 1; num <= 9; num++) {
            if (_isValid(board, row, col, num)) {
              board[row][col] = num;
              if (_solveBoard(board)) return true;
              board[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isValid(List<List<int>> board, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num || board[i][col] == num) return false;
      int boxRow = 3 * (row ~/ 3) + i ~/ 3;
      int boxCol = 3 * (col ~/ 3) + i % 3;
      if (board[boxRow][boxCol] == num) return false;
    }
    return true;
  }

  void _removeNumbers() {
    int cellsToRemove = 40 + _random.nextInt(10); // Remove 40-50 numbers
    for (int i = 0; i < cellsToRemove; i++) {
      int row = _random.nextInt(9);
      int col = _random.nextInt(9);
      while (board[row][col] == 0) {
        row = _random.nextInt(9);
        col = _random.nextInt(9);
      }
      board[row][col] = 0;
    }
  }
}
