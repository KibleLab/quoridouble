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

class WallTempWidget extends StatelessWidget {
  final String wallTempWidget;
  final double cellSize;
  final double spacing;
  final double touchMargin;
  final VoidCallback onTap;

  const WallTempWidget({
    super.key,
    required this.wallTempWidget,
    required this.cellSize,
    required this.spacing,
    required this.touchMargin,
    required this.onTap, 
  });

  @override
  Widget build(BuildContext context) {
    // wallTempWidget가 빈 문자열이면 아무것도 렌더링하지 않음
    if (wallTempWidget.isEmpty) {
      return const SizedBox.shrink();
    }

    // 처음 문자열이 단일 숫자(True)인지 문자(False)인지 확인
    bool isHorizontalWall = wallTempWidget[0].contains(RegExp(r'[0-9]'));

    int topCon =
        isHorizontalWall ? int.parse(wallTempWidget[0]) : int.parse(wallTempWidget[1]);

    int leftCon = isHorizontalWall
        ? wallTempWidget[1].codeUnitAt(0) - 'A'.codeUnitAt(0)
        : wallTempWidget[0].codeUnitAt(0) - 'A'.codeUnitAt(0);

    final double top = isHorizontalWall
        ? topCon * cellSize + spacing * (topCon - 1)
        : (topCon - 1) * (cellSize + spacing);

    final double left = isHorizontalWall
        ? leftCon * (cellSize + spacing)
        : (leftCon + 1) * cellSize + spacing * leftCon;

    return Positioned(
      // 터치 영역을 넓히는 마진만큼 제외
      top: top - (isHorizontalWall ? touchMargin : 0),
      left: left - (isHorizontalWall ? 0 : touchMargin),
      child: GestureDetector(
        // 비어있는 영역도 터치가 가능하도록 설정
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: isHorizontalWall ? 2 * cellSize + spacing : spacing,
          height: isHorizontalWall ? spacing : 2 * cellSize + spacing,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 127, 80).withOpacity(0.5),
            borderRadius: BorderRadius.circular(1000),
          ),
          margin: EdgeInsets.only(
            top: isHorizontalWall ? touchMargin : 0,
            bottom: isHorizontalWall ? touchMargin : 0,
            left: isHorizontalWall ? 0 : touchMargin,
            right: isHorizontalWall ? 0 : touchMargin,
          ),
        ),
      ),
    );
  }
}
