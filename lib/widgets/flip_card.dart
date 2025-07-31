import 'dart:math';

import 'package:flutter/material.dart';

class FlipCard extends StatelessWidget {
  final bool isFlipped;
  final Widget front;
  final Widget back;
  final Duration duration;
  final VoidCallback onTap;

  const FlipCard({
    super.key,
    required this.isFlipped,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 400),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: isFlipped ? 1.0 : 0.0),
        duration: duration,
        builder: (context, value, child) {
          final angle = value * pi;
          final isFrontVisible = angle <= pi / 2;

          return Transform(
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
            alignment: Alignment.center,
            child:
                isFrontVisible
                    ? front
                    : Transform(
                      transform: Matrix4.identity()..rotateY(pi),
                      alignment: Alignment.center,
                      child: back,
                    ),
          );
        },
      ),
    );
  }
}
