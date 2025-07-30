import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matching_pairs_game/models/card_item.dart';

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

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _time++;
      });
    });
  }

  void _checkGameFinished() {
    final allMatched = _cards.every((card) => card.state == CardState.matched);
    if (allMatched) {
      _timer?.cancel();
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
            const Text(
              'Level: Easy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Time: $_time seconds',
                style: const TextStyle(
                  fontSize: 24,
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
                  return InkWell(
                    onTap: () {
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
                              Future.delayed(const Duration(seconds: 2), () {
                                setState(() {
                                  selectedCard!.setStateTo(CardState.unflipped);
                                  card.setStateTo(CardState.unflipped);
                                  selectedCard = null;
                                });
                              });
                            }
                          }
                        }
                      });
                    },
                    child: Card(
                      elevation: 8,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      color: _cards[index].color,
                      shadowColor: Colors.transparent,
                      child: Center(
                        child: Text(
                          _cards[index].displayLabel,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
