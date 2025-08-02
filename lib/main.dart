import 'package:flutter/material.dart';
import 'package:matching_pairs_game/constants/observers.dart';
import 'package:matching_pairs_game/screens/difficulty_selection_screen.dart';
import 'package:matching_pairs_game/screens/game_screen.dart';
import 'package:matching_pairs_game/constants/enums.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: const DifficultySelectionScreen(),
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      routes: {
        '/easy': (_) => GameScreen(difficulty: Difficulty.easy),
        '/medium': (_) => GameScreen(difficulty: Difficulty.medium),
        '/hard': (_) => GameScreen(difficulty: Difficulty.hard),
      },
    );
  }
}
