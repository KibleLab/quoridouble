import 'package:flutter/material.dart';

class BoardWidget extends StatelessWidget {
  final double spacing;

  const BoardWidget({super.key, required this.spacing});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 9,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      children: List.generate(9 * 9, (index) => const BoardTile()),
    );
  }
}

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
