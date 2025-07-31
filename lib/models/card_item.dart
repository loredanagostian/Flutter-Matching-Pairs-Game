import 'package:flutter/material.dart';

enum CardState { unflipped, flipped, matched }

class CardItem {
  final String flippedLabel;
  String unflippedLabel;
  Color color;
  CardState state;
  String get displayLabel =>
      state == CardState.flipped || state == CardState.matched
          ? flippedLabel
          : unflippedLabel;

  CardItem({
    required this.flippedLabel,
    this.unflippedLabel = "?",
    this.color = Colors.grey,
    this.state = CardState.unflipped,
  });

  void setStateTo(CardState newState) {
    state = newState;
    switch (newState) {
      case CardState.unflipped:
        color = Colors.grey;
        break;
      case CardState.flipped:
        color = Colors.lightBlue[100]!;
        break;
      case CardState.matched:
        color = Colors.lightGreen[300]!;
        break;
    }
  }
}
