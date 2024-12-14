import 'package:flutter/material.dart';
import 'package:quoridouble/widgets/gameboard/components1/player_pin.dart';

class PlayerPins extends StatelessWidget {
  final List<int> user1;
  final List<int> user2;
  final double cellSize;
  final double spacing;
  final int isFirst;

  const PlayerPins({
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
        PlayerPin(
          position: user1,
          cellSize: cellSize,
          spacing: spacing,
          assetPath: isFirst == 0
              ? 'assets/images/white_pin.svg'
              : 'assets/images/black_pin.svg',
        ),
        PlayerPin(
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
