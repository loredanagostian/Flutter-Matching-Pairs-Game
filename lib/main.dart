import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matching_pairs_game/models/card_item.dart';
import 'package:matching_pairs_game/widgets/flip_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: const MyHomePage(title: 'Flutter Matching Pairs Game'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _time = 0;
  Timer? _timer;
  final List<CardItem> _cards = [
    CardItem(flippedLabel: '🔴'),
    CardItem(flippedLabel: '🔴'),
    CardItem(flippedLabel: '🟡'),
    CardItem(flippedLabel: '🟡'),
    CardItem(flippedLabel: '🟣'),
    CardItem(flippedLabel: '🟣'),
    CardItem(flippedLabel: '🔵'),
    CardItem(flippedLabel: '🔵'),
  ]..shuffle();
  CardItem? selectedCard;
  bool _isBusy = false;
  int? _bestTime;

  @override
  void initState() {
    super.initState();
    _loadBestTime();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadBestTime() async {
    final prefs = await SharedPreferences.getInstance();
    final bestTime = prefs.getInt('best_time');
    if (bestTime == 0) {
      await prefs.setInt('best_time', -1);
    }

    setState(() {
      _bestTime = prefs.getInt('best_time');
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _time++;
      });
    });
  }

  void _checkGameFinished() async {
    final allMatched = _cards.every((card) => card.state == CardState.matched);
    if (allMatched) {
      _timer?.cancel();

      final prefs = await SharedPreferences.getInstance();
      final savedBestTime = prefs.getInt('best_time');

      if (savedBestTime == null ||
          savedBestTime == -1 ||
          _time < savedBestTime) {
        if (_time > 0) {
          // Save new best time
          await prefs.setInt('best_time', _time);
          setState(() {
            _bestTime = _time;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Level: Easy',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Visibility(
                  visible: _bestTime != null && _bestTime! > 0,
                  child: Text(
                    'Best time: ${_bestTime ?? "-"} seconds',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Time: $_time seconds',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: List.generate(_cards.length, (index) {
                  return FlipCard(
                    isFlipped: _cards[index].state != CardState.unflipped,
                    onTap: () {
                      if (_isBusy) return;

                      setState(() {
                        final card = _cards[index];
                        if (card.state == CardState.unflipped) {
                          card.setStateTo(CardState.flipped);
                          if (selectedCard == null) {
                            selectedCard = card;
                          } else {
                            if (selectedCard!.flippedLabel ==
                                    card.flippedLabel &&
                                selectedCard != card) {
                              selectedCard!.setStateTo(CardState.matched);
                              card.setStateTo(CardState.matched);
                              selectedCard = null;
                              _checkGameFinished();
                            } else {
                              _isBusy = true;
                              Future.delayed(const Duration(seconds: 1), () {
                                setState(() {
                                  selectedCard!.setStateTo(CardState.unflipped);
                                  card.setStateTo(CardState.unflipped);
                                  selectedCard = null;
                                  _isBusy = false;
                                });
                              });
                            }
                          }
                        }
                      });
                    },
                    front: Card(
                      elevation: 8,
                      color: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          '?',
                          style: TextStyle(fontSize: 28, color: Colors.white),
                        ),
                      ),
                    ),
                    back: Card(
                      elevation: 8,
                      color:
                          _cards[index].state == CardState.matched
                              ? Colors.green
                              : Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          _cards[index].flippedLabel,
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    // Reset card states and shuffle
                    for (var card in _cards) {
                      card.setStateTo(CardState.unflipped);
                    }
                    _cards.shuffle();

                    // Reset selected card and time
                    selectedCard = null;
                    _time = 0;

                    // Cancel old timer and start new one
                    _timer?.cancel();
                    _startTimer();

                    // Load existing best time again (in case it was beaten)
                    _loadBestTime();
                  });
                },
                child: const Text('Play Again', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
