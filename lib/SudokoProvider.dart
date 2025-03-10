import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SudokuProvider extends ChangeNotifier {
  List<List<int>> board = List.generate(9, (_) => List.filled(9, 0));
  List<List<int>> solution = List.generate(9, (_) => List.filled(9, 0));
  List<List<List<int>>> boardHistory = []; // Undo history
  List<String> winHistory = []; // Stores win history
  Set<Point<int>> wrongCells = {}; // Tracks incorrect inputs
  int lives = 3; // Start with 3 lives
  bool isGameOver = false; // Flag to track if the game is over

  static const String PREFS_WIN_HISTORY_KEY = 'win_history';

  final List<String> winMessages = [
    "I Love You! I am sure that you are my wife in every universe 💕",
    "You complete me, Rinky, in ways I never knew possible. Always and forever. 💍",
    "I want to die with this dream! Because I still can't believe that we are married! 🤯",
    "Amader bacchar brilliant howar possibility high 🤩",
    "Choosing BAGHC was the best decision ever! 😁",
    "In your eyes, I see my forever. I love you more every single day. 💘",
    "Inky pinky ponky, Rinky is not a donkey 😎",
  ];
  final Random _random = Random();

  SudokuProvider() {
    generateSudoku();
    _loadWinHistory(); // Load win history when provider is created
  }

  // Load win history from SharedPreferences
  Future<void> _loadWinHistory() async {
    final prefs = await SharedPreferences.getInstance();
    winHistory = prefs.getStringList(PREFS_WIN_HISTORY_KEY) ?? [];
    notifyListeners();
  }

  // Save win history to SharedPreferences
  Future<void> _saveWinHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(PREFS_WIN_HISTORY_KEY, winHistory);
  }

  /// 🔄 Resets the game and starts a new Sudoku
  void resetGame() {
    generateSudoku();
    isGameOver = false; // Reset game over flag
    notifyListeners();
  }

  /// 🎲 Generates a new Sudoku puzzle
  void generateSudoku() {
    board = _generateFullBoard();
    solution = board.map((row) => List<int>.from(row)).toList();
    _removeNumbers();
    boardHistory.clear();
    wrongCells.clear();
    lives = 3; // Reset lives
    isGameOver = false; // Ensure the game is not over when generating
    notifyListeners();
  }

  /// ❤️ Show hearts based on lives
  String get hearts {
    int totalHearts = 3;
    int fadedHearts = totalHearts - lives;
    return '❤️' * lives + '🖤' * fadedHearts; // Show hearts based on lives
  }

  /// 🏆 Returns a random win message
  String getRandomWinMessage() {
    return winMessages[_random.nextInt(winMessages.length)];
  }

  /// ✅ Checks if the game is won
  bool isGameWon() {
    return board.every((row) => row.every((cell) => cell != 0)) &&
        _isBoardCorrect();
    // return true;
  }

  /// 🔍 Verifies if the board is correct
  bool _isBoardCorrect() {
    for (int i = 0; i < 9; i++) {
      Set<int> rowSet = {}, colSet = {}, boxSet = {};
      for (int j = 0; j < 9; j++) {
        if (board[i][j] != 0 && !rowSet.add(board[i][j])) return false;
        if (board[j][i] != 0 && !colSet.add(board[j][i])) return false;
        int boxRow = 3 * (i ~/ 3) + j ~/ 3;
        int boxCol = 3 * (i % 3) + j % 3;
        if (board[boxRow][boxCol] != 0 && !boxSet.add(board[boxRow][boxCol])) {
          return false;
        }
      }
    }
    return true;
  }

  /// 🔢 Updates a cell and checks for mistakes
  void updateCell(int row, int col, int value) {
    if (board[row][col] != 0 || value < 1 || value > 9 || isGameOver) return;

    // Save current state for undo
    boardHistory.add(board.map((row) => List<int>.from(row)).toList());

    if (value == solution[row][col]) {
      board[row][col] = value;
      wrongCells.remove(Point(row, col)); // Remove if corrected
    } else {
      wrongCells.add(Point(row, col)); // Mark incorrect
      lives--; // Lose a life

      if (lives == 0) {
        isGameOver = true; // Game Over
        notifyListeners();
      }
    }
    notifyListeners();
  }

  /// ⏪ Undo last move
  void undo() {
    if (boardHistory.isNotEmpty && !isGameOver) {
      board = boardHistory.removeLast();
      notifyListeners();
    }
  }

  /// 🏆 Adds a win to history
  void addWinToHistory() {
    final now = DateTime.now();
    final formatter = DateFormat('MMM dd, yyyy HH:mm');
    final timestamp = formatter.format(now);
    winHistory.add("$timestamp");
    _saveWinHistory(); // Save to local storage
    notifyListeners();
  }

  /// 🔢 Generates a full valid Sudoku board
  List<List<int>> _generateFullBoard() {
    List<List<int>> board = List.generate(9, (_) => List.filled(9, 0));
    _fillDiagonalBoxes(board);
    _solveBoard(board);
    return board;
  }

  /// 🔳 Fills the diagonal 3x3 boxes
  void _fillDiagonalBoxes(List<List<int>> board) {
    for (int i = 0; i < 9; i += 3) {
      _fillBox(board, i, i);
    }
  }

  /// 🎲 Randomly fills a 3x3 box
  void _fillBox(List<List<int>> board, int row, int col) {
    List<int> nums = List.generate(9, (index) => index + 1)..shuffle();
    int index = 0;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        board[row + i][col + j] = nums[index++];
      }
    }
  }

  /// 🧠 Solves the Sudoku board using backtracking
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

  /// 🔍 Checks if a number can be placed in a cell
  bool _isValid(List<List<int>> board, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num || board[i][col] == num) return false;
      int boxRow = 3 * (row ~/ 3) + i ~/ 3;
      int boxCol = 3 * (col ~/ 3) + i % 3;
      if (board[boxRow][boxCol] == num) return false;
    }
    return true;
  }

  /// ✂ Removes numbers to create a puzzle
  void _removeNumbers() {
    int cellsToRemove = 40 + _random.nextInt(10);
    Set<Point<int>> removedCells = {};

    while (removedCells.length < cellsToRemove) {
      int row = _random.nextInt(9);
      int col = _random.nextInt(9);

      if (!removedCells.contains(Point(row, col))) {
        removedCells.add(Point(row, col));
        board[row][col] = 0;
      }
    }
  }
}
