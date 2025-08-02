import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:matching_pairs_game/models/card_item.dart';
import 'package:matching_pairs_game/models/score_entry.dart';
import 'package:matching_pairs_game/widgets/flip_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:matching_pairs_game/constants/enums.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.difficulty});

  final Difficulty difficulty;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _time = 0;
  Timer? _timer;
  List<CardItem> _cards = [];
  CardItem? selectedCard;
  bool _isBusy = false;
  ScoreEntry? _bestEntry;
  bool _isNewRecord = false;
  int _moves = 0;

  int get cardCount {
    switch (widget.difficulty) {
      case Difficulty.easy:
        return 8;
      case Difficulty.medium:
        return 12;
      case Difficulty.hard:
        return 16;
    }
  }

  String get prefsKey => 'bestEntry_${widget.difficulty.name}';

  String get difficultyLabel => switch (widget.difficulty) {
    Difficulty.easy => 'Easy',
    Difficulty.medium => 'Medium',
    Difficulty.hard => 'Hard',
  };

  @override
  void initState() {
    super.initState();
    _generateCards();
    _loadBestEntry();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generateCards() {
    final emojis = ['🔴', '🟡', '🟣', '🔵', '🟢', '🟠', '⚫', '⚪'];
    final pairsNeeded = cardCount ~/ 2;
    final selected = emojis.take(pairsNeeded).toList();
    _cards =
        [
          ...selected,
          ...selected,
        ].map((e) => CardItem(flippedLabel: e)).toList();
    _cards.shuffle();
  }

  Future<void> _loadBestEntry() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(prefsKey);
    if (jsonStr != null) {
      final entry = ScoreEntry.fromJson(jsonDecode(jsonStr));
      setState(() {
        _bestEntry = entry;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _time++);
    });
  }

  double getDifficultyMultiplier(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 1.0;
      case Difficulty.medium:
        return 1.5;
      case Difficulty.hard:
        return 2.0;
    }
  }

  void _checkGameFinished() async {
    final allMatched = _cards.every((card) => card.state == CardState.matched);
    if (!allMatched) return;

    _timer?.cancel();

    const baseScore = 1000;
    const timePenalty = 2; // 2 points lost per second
    const movePenalty = 3; // 3 points lost per move

    double difficultyMultiplier = getDifficultyMultiplier(widget.difficulty);
    int rawScore = baseScore - (_time * timePenalty) - (_moves * movePenalty);
    rawScore = rawScore < 0 ? 0 : rawScore;
    int finalScore = (rawScore * difficultyMultiplier).round();

    // Show score
    //
    // Example:
    // Difficulty: Medium
    // Time: 40 seconds
    // Moves: 30
    //
    // Score = 1000 - (40 * 2) - (30 * 3) = 1000 - 80 - 90 = 830
    // Final Score = 830 * 1.5 = 1245
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Game Completed!'),
            content: Text(
              'Your score: $finalScore\n'
              'Time: $_time sec\nMoves: $_moves',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );

    final prefs = await SharedPreferences.getInstance();
    final existingJson = prefs.getString(prefsKey);
    ScoreEntry? existingEntry;

    if (existingJson != null) {
      existingEntry = ScoreEntry.fromJson(jsonDecode(existingJson));
    }

    final newEntry = ScoreEntry(score: finalScore, time: _time, moves: _moves);

    bool isNewRecord =
        existingEntry == null || finalScore > existingEntry.score;

    if (isNewRecord) {
      await prefs.setString(prefsKey, jsonEncode(newEntry.toJson()));
    }

    setState(() {
      if (isNewRecord) {
        _bestEntry = newEntry;
      }

      _isNewRecord = isNewRecord;
    });
  }

  void _handleCardTap(CardItem card) {
    if (_isBusy) return;

    setState(() {
      if (card.state == CardState.unflipped) {
        _moves++;
        card.state = CardState.flipped;

        if (selectedCard == null) {
          selectedCard = card;
        } else {
          if (selectedCard!.flippedLabel == card.flippedLabel &&
              selectedCard != card) {
            selectedCard!.state = CardState.matched;
            card.state = CardState.matched;
            selectedCard = null;
            _checkGameFinished();
          } else {
            _isBusy = true;

            Future.delayed(const Duration(seconds: 0, milliseconds: 500), () {
              setState(() {
                selectedCard!.state = CardState.unflipped;
                card.state = CardState.unflipped;
                selectedCard = null;
                _isBusy = false;
              });
            });
          }
        }
      }
    });
  }

  Widget _buildFrontCard() {
    return Card(
      elevation: 8,
      color: Colors.grey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: const Center(
        child: Text('?', style: TextStyle(fontSize: 28, color: Colors.white)),
      ),
    );
  }

  Widget _buildBackCard(CardItem card) {
    return Card(
      elevation: 8,
      color:
          card.state == CardState.matched
              ? Colors.lightGreen[300]!
              : Colors.lightBlue[100]!,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Text(
          card.displayLabel,
          style: const TextStyle(fontSize: 28, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Level: $difficultyLabel')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_bestEntry != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Best score: ${_bestEntry!.score}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isNewRecord ? Colors.green : Colors.black,
                        ),
                      ),
                      Text(
                        '⏱️ ${_bestEntry!.time}s   🔁 ${_bestEntry!.moves} moves',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                'Time: $_time seconds',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = switch (widget.difficulty) {
                      Difficulty.easy => 3,
                      Difficulty.medium => 3,
                      Difficulty.hard => 4,
                    };

                    final totalCards = switch (widget.difficulty) {
                      Difficulty.easy => 8,
                      Difficulty.medium => 12,
                      Difficulty.hard => 16,
                    };

                    final rowCount = (totalCards / crossAxisCount).ceil();
                    final spacing = 8.0 * (rowCount - 1);
                    final availableHeight = constraints.maxHeight - spacing;
                    final childHeight = availableHeight / rowCount;
                    final childWidth = constraints.maxWidth / crossAxisCount;

                    final aspectRatio = childWidth / childHeight;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: aspectRatio,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(_cards.length, (index) {
                        final card = _cards[index];
                        return FlipCard(
                          isFlipped: card.state != CardState.unflipped,
                          onTap: () => _handleCardTap(card),
                          front: _buildFrontCard(),
                          back: _buildBackCard(card),
                        );
                      }),
                    );
                  },
                ),
              ),

              TextButton(
                onPressed: () {
                  setState(() {
                    for (var card in _cards) {
                      card.state = CardState.unflipped;
                    }
                    _cards.shuffle();
                    selectedCard = null;
                    _time = 0;
                    _moves = 0;
                    _isBusy = false;
                    _isNewRecord = false;
                    _timer?.cancel();
                    _startTimer();
                    _loadBestEntry();
                  });
                },
                child: const Text('Play Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
