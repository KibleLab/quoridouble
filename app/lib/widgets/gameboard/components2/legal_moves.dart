import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quoridouble/utils/game.dart';

class LegalMoves extends StatelessWidget {
  final GameState gameState;
  final List<int> user1;
  final double cellSize;
  final double spacing;

  const LegalMoves({
    super.key,
    required this.gameState,
    required this.user1,
    required this.cellSize,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    // 회전 각도를 계산하는 함수를 추가함.
    double getRotationAngle(List<int> target) {
      final int x = target[0];
      final int y = target[1];

      return (atan2(y, -x) + 2 * pi) % (2 * pi);
    }

    return Stack(
      children: gameState.legalMoves().map((target) {
        return Positioned(
          top: (target[0] ~/ 2 + user1[0]) * (cellSize + spacing),
          left: (target[1] ~/ 2 + user1[1]) * (cellSize + spacing),
          width: cellSize,
          height: cellSize,
          child: Padding(
            padding: EdgeInsets.all(spacing),
            child: Transform.rotate(
              angle: getRotationAngle(target),
              child: SvgPicture.asset('assets/images/up_circle.svg'),
            ),
          ),
        );
      }).toList(),
    );
  }
}
