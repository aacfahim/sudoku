import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_app/SudokoProvider.dart';
import 'dart:math';

import 'package:sudoku_app/SudokuBoard.dart';

class SudokuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sudokuProvider = context.watch<SudokuProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Sudoku Game"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Made with 💖\nby Ashfaq",
              style: TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Rinky's Sudoku",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text("Notun kore khelba?\nEkhane tip deo"),
              onTap: () {
                context.read<SudokuProvider>().resetGame();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text("Win History 👇"),
              onTap: () => Navigator.pop(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: sudokuProvider.winHistory
                    .map((history) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            history, // Add the history text here
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Display Hearts
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '❤️' * sudokuProvider.lives,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  TextSpan(
                    text: '🖤' * (3 - sudokuProvider.lives),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400], // Light ash color
                    ),
                  ),
                ],
              ),
            ),
          ),

          // If game is over, show the "Game Over" message
          if (sudokuProvider.lives == 0)
            Center(
              child: Column(
                children: [
                  Text(
                    "Game Over",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      sudokuProvider.resetGame();
                    },
                    child: Text("Start a new game"),
                  ),
                ],
              ),
            )
          else
            Expanded(child: SudokuBoard()), // Otherwise, show the board

          // Show the game action buttons
          if (sudokuProvider.lives > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: sudokuProvider.boardHistory.isNotEmpty
                      ? () => sudokuProvider.undo()
                      : null,
                  child: Text("Undo"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (sudokuProvider.isGameWon()) {
                      sudokuProvider.addWinToHistory();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Congrats! You Won 🎉"),
                          content: Text(sudokuProvider.getRandomWinMessage()),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("OK"),
                            ),
                          ],
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Solve e to koro nai 😒")),
                      );
                    }
                  },
                  child: Text("Check Result"),
                ),
              ],
            ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
