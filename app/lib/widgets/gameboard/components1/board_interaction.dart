import 'package:flutter/material.dart';

class BoardInteraction extends StatefulWidget {
  final String tempWall;
  final double screenWidth;
  final Offset? startPoint;
  final Offset? endPoint;

  final Function emptyTempWall;
  final Function(Offset startPoint, Offset? endPoint) setPoint;

  final int userWallCount;
  final Function(double distance, Offset details) onPanUpdate;
  final Function(Offset startPoint) setPlayer;

  final Function(Offset startPoint, Offset endPoint) setWallTemp;
  final Function resetPoint;

  const BoardInteraction({
    super.key,
    required this.tempWall,
    required this.screenWidth,
    required this.startPoint,
    required this.endPoint,
    required this.emptyTempWall,
    required this.setPoint,
    required this.userWallCount,
    required this.onPanUpdate,
    required this.setPlayer,
    required this.setWallTemp,
    required this.resetPoint,
  });

  @override
  BoardInteractionState createState() => BoardInteractionState();
}

class BoardInteractionState extends State<BoardInteraction> {
  Offset? restrictedEnd;

  // restrictedEnd 계산 함수
  void calculateRestrictedEnd(Offset start, Offset end) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;

    if (dx.abs() > dy.abs()) {
      double length = dx.abs();
      restrictedEnd = Offset(start.dx + length * dx.sign, start.dy);
    } else {
      double length = dy.abs();
      restrictedEnd = Offset(start.dx, start.dy + length * dy.sign);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: widget.tempWall.isEmpty
          ? null
          : (details) {
              widget.emptyTempWall();
            },
      onPanStart: widget.tempWall.isEmpty
          ? (details) {
              widget.setPoint(details.localPosition, null);
            }
          : null,
      onPanUpdate: (details) {
        if (widget.startPoint != null &&
            details.localPosition.dx >= 0 &&
            details.localPosition.dx <= widget.screenWidth - 36 &&
            details.localPosition.dy >= 0 &&
            details.localPosition.dy <= widget.screenWidth - 36 &&
            widget.userWallCount > 0) {
          double distance =
              (widget.startPoint! - details.localPosition).distance;
          widget.onPanUpdate(distance, details.localPosition);

          // restrictedEnd 계산
          calculateRestrictedEnd(widget.startPoint!, details.localPosition);
        }
      },
      onPanEnd: widget.tempWall.isEmpty
          ? (details) {
              if (widget.startPoint == null) {
                print('startPoint가 null입니다.');
                return;
              }

              if (widget.endPoint == null) {
                widget.setPlayer(widget.startPoint!);
              } else if (restrictedEnd != null) {
                widget.setWallTemp(
                    widget.startPoint!, restrictedEnd!); // restrictedEnd 사용
              } else {
                print('restrictedEnd가 null입니다.');
              }

              widget.resetPoint();
            }
          : null,
    );
  }
}
