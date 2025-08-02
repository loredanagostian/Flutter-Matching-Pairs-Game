import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:matching_pairs_game/constants/enums.dart';
import 'package:matching_pairs_game/constants/observers.dart';
import 'package:matching_pairs_game/models/score_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DifficultySelectionScreen extends StatefulWidget {
  const DifficultySelectionScreen({super.key});

  @override
  State<DifficultySelectionScreen> createState() =>
      _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState extends State<DifficultySelectionScreen>
    with RouteAware {
  Map<Difficulty, ScoreEntry?> bestEntries = {
    Difficulty.easy: null,
    Difficulty.medium: null,
    Difficulty.hard: null,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    _loadBestTimes();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadBestTimes();
  }

  Future<void> _loadBestTimes() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      for (var difficulty in Difficulty.values) {
        final jsonStr = prefs.getString('bestEntry_${difficulty.name}');
        if (jsonStr != null) {
          bestEntries[difficulty] = ScoreEntry.fromJson(jsonDecode(jsonStr));
        } else {
          bestEntries[difficulty] = null;
        }
      }
    });
  }

  void _selectDifficulty(BuildContext context, Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        Navigator.pushNamed(context, '/easy');
        break;
      case Difficulty.medium:
        Navigator.pushNamed(context, '/medium');
        break;
      case Difficulty.hard:
        Navigator.pushNamed(context, '/hard');
        break;
    }
  }

  Widget _buildButton(Difficulty difficulty, Color color) {
    final entry = bestEntries[difficulty];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () => _selectDifficulty(context, difficulty),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(
            difficulty.name.capitalize(),
            style: const TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(height: 4),
        if (entry != null) ...[
          Text(
            'Best score: ${entry.score}',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Text(
            '⏱️ ${entry.time}s   🔁 ${entry.moves} moves',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ] else
          const Text(
            'Best score: Not recorded',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        const SizedBox(height: 50),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Matching Pairs Game'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.blue),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('How are scores calculated?'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Your score is calculated based on the following factors:\n\n'
                          '1. Base Score: 1000 points\n'
                          '2. Time Penalty: 2 points lost per second\n'
                          '3. Move Penalty: 3 points lost per move\n'
                          '4. Difficulty Multiplier:\n'
                          '   - Easy: x1.0\n'
                          '   - Medium: x1.5\n'
                          '   - Hard: x2.0\n',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(Difficulty.easy, Colors.lightGreen[300]!),
              _buildButton(Difficulty.medium, Colors.yellow[300]!),
              _buildButton(Difficulty.hard, Colors.red[300]!),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
