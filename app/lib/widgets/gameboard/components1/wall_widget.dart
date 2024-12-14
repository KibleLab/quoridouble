import 'package:flutter/material.dart';

class WallWidget extends StatelessWidget {
  final String wallInfo;
  final double cellSize;
  final double spacing;

  const WallWidget({
    super.key,
    required this.wallInfo,
    required this.cellSize,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    // 문자열이 단일 숫자(True)인지 문자(False)인지 확인
    bool isHorizontalWall = wallInfo[0].contains(RegExp(r'[0-9]'));

    int topCon =
        isHorizontalWall ? int.parse(wallInfo[0]) : int.parse(wallInfo[1]);

    int leftCon = isHorizontalWall
        ? wallInfo[1].codeUnitAt(0) - 'A'.codeUnitAt(0)
        : wallInfo[0].codeUnitAt(0) - 'A'.codeUnitAt(0);

    final double top = isHorizontalWall
        ? topCon * cellSize + spacing * (topCon - 1)
        : (topCon - 1) * (cellSize + spacing);

    final double left = isHorizontalWall
        ? leftCon * (cellSize + spacing)
        : (leftCon + 1) * cellSize + spacing * leftCon;

    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: isHorizontalWall ? 2 * cellSize + spacing : spacing,
        height: isHorizontalWall ? spacing : 2 * cellSize + spacing,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 127, 80),
          borderRadius:BorderRadius.circular(1000),
        ),
      ),
    );
  }
}
