import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'SudokoProvider.dart';
import 'SudokuScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SudokuProvider(),

      child: MaterialApp(
        title: 'Sudoku Game',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: SudokuScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

