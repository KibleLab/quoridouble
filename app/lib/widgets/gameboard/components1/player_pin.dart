import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PlayerPin extends StatelessWidget {
  final List<int> position; // [row, col]
  final double cellSize;
  final double spacing;
  final String assetPath;
  final Duration duration;
  final Curve curve;

  const PlayerPin({
    super.key,
    required this.position,
    required this.cellSize,
    required this.spacing,
    required this.assetPath,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: duration,
      curve: curve,
      top: position[0] * (cellSize + spacing),
      left: position[1] * (cellSize + spacing),
      width: cellSize,
      height: cellSize,
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: SvgPicture.asset(assetPath),
      ),
    );
  }
}
