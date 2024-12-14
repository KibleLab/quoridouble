import 'package:flutter/material.dart';
import 'package:quoridouble/widgets/gameboard/components1/wall_widget.dart';

class Walls extends StatelessWidget {
  final List<String> wall;
  final double cellSize;
  final double spacing;

  const Walls({
    super.key,
    required this.wall,
    required this.cellSize,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: wall.map((wallInfo) {
        return WallWidget(
          wallInfo: wallInfo,
          cellSize: cellSize,
          spacing: spacing,
        );
      }).toList(),
    );
  }
}
