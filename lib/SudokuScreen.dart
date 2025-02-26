import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'SudokoProvider.dart';

class SudokuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sudoku Game"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Made with 😘\nby Ashfaq",
              style: TextStyle(fontSize: 8),
            ),
          )
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
                context.read<SudokuProvider>().generateSudoku();
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text("Win History 👇"),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: context
                    .watch<SudokuProvider>()
                    .winHistory
                    .map((history) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            history,
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
          Expanded(child: SudokuBoard()),
          TextButton(
              onPressed: () {
                context.read<SudokuProvider>().undo();
              },
              child: Text("Undo")),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton(
              onPressed: () {
                if (context.read<SudokuProvider>().isGameWon()) {
                  context
                      .read<SudokuProvider>()
                      .addWinToHistory(); // Save the win history
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Congrats! You Won 😍"),
                      content: Text(
                          context.read<SudokuProvider>().getRandomWinMessage()),
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
              child: Text("Press ME to check 😉"),
            ),
          ),
        ],
      ),
    );
  }
}

class SudokuBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 9,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 81,
      itemBuilder: (context, index) {
        int row = index ~/ 9;
        int col = index % 9;
        int value = context.watch<SudokuProvider>().board[row][col];

        // Determine if the current cell is in the border of a 3x3 block
        bool isIn3x3Border = (row % 3 == 0 || col % 3 == 0);

        return GestureDetector(
          onTap: () {
            if (value == 0) {
              _showNumberInputDialog(context, row, col);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: (col % 3 == 0) ? Colors.black : Colors.transparent,
                  width: 2,
                ),
                top: BorderSide(
                  color: (row % 3 == 0) ? Colors.black : Colors.transparent,
                  width: 2,
                ),
                right: BorderSide(
                  color: (col % 3 == 2) ? Colors.black : Colors.transparent,
                  width: 2,
                ),
                bottom: BorderSide(
                  color: (row % 3 == 2) ? Colors.black : Colors.transparent,
                  width: 2,
                ),
              ),
              color: value == 0 ? Colors.white : Colors.grey[300],
            ),
            child: Container(
              margin: EdgeInsets.all(1),
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      Colors.grey.withOpacity(0.5), // subtle inner border color
                  width: 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  value == 0 ? "" : value.toString(),
                  style: TextStyle(fontSize: 18),
                ),
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
          title: Text("Enter a number babe"),
          content: Wrap(
            children: List.generate(9, (index) {
              return TextButton(
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
