import 'package:flutter/material.dart';
import 'package:quoridouble/widgets/gameboard/components1/board_tile.dart';

class GameGrid extends StatelessWidget {
  final double spacing;

  const GameGrid({super.key, required this.spacing});

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
