import 'package:flutter/material.dart';

class BoardTile extends StatelessWidget {
  final double borderRadius;
  final Color color;

  const BoardTile({
    super.key,
    this.borderRadius = 2.5,
    this.color = const Color.fromARGB(255, 237, 237, 237),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
