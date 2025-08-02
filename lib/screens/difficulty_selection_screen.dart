import 'package:flutter/material.dart';
import 'package:matching_pairs_game/constants/enums.dart';
import 'package:matching_pairs_game/constants/observers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DifficultySelectionScreen extends StatefulWidget {
  const DifficultySelectionScreen({super.key});

  @override
  State<DifficultySelectionScreen> createState() =>
      _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState extends State<DifficultySelectionScreen>
    with RouteAware {
  Map<Difficulty, int?> bestScores = {
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
      bestScores[Difficulty.easy] = prefs.getInt('bestScore_easy');
      bestScores[Difficulty.medium] = prefs.getInt('bestScore_medium');
      bestScores[Difficulty.hard] = prefs.getInt('bestScore_hard');
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
        Text(
          'Best score: ${bestScores[difficulty] ?? "Not recorded"}',
          style: const TextStyle(fontSize: 14, color: Colors.black54),
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
