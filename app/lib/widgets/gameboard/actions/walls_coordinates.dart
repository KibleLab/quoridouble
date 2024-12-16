import 'package:flutter/material.dart';
import 'package:quoridouble/widgets/gameboard/boards/wall_widget.dart';

class WallsCoordinates extends StatelessWidget {
  final List<String> wall;
  final double cellSize;
  final double spacing;

  const WallsCoordinates({
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
