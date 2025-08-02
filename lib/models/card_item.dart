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
}
