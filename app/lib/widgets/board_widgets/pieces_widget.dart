import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PiecesWidget extends StatelessWidget {
  final List<int> user1;
  final List<int> user2;
  final double cellSize;
  final double spacing;
  final int isFirst;

  const PiecesWidget({
    super.key,
    required this.user1,
    required this.user2,
    required this.cellSize,
    required this.spacing,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Piece(
          position: user1,
          cellSize: cellSize,
          spacing: spacing,
          assetPath: isFirst == 0
              ? 'assets/images/white_pin.svg'
              : 'assets/images/black_pin.svg',
        ),
        Piece(
          position: user2,
          cellSize: cellSize,
          spacing: spacing,
          assetPath: isFirst == 1
              ? 'assets/images/white_pin.svg'
              : 'assets/images/black_pin.svg',
        ),
      ],
    );
  }
}

class Piece extends StatelessWidget {
  final List<int> position; // [row, col]
  final double cellSize;
  final double spacing;
  final String assetPath;
  final Duration duration;
  final Curve curve;

  const Piece({
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
