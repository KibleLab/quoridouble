import 'package:flutter/material.dart';

class BoardInteractionWidget extends StatefulWidget {
  final String wallTempCoord;
  final double boardSize;
  final double boardBoarder;
  final double cellSize;
  final double spacing;
  final Offset? startPoint;
  final Offset? endPoint;

  final Function onEmptyWallTemp;
  final Function(Offset startPoint, Offset? endPoint) setPoint;

  final int userWallCount;
  final Function(double distance, Offset details) updatePoint;
  final Function(Offset startPoint, double cellSize, double spacing) onSetPlayer;

  final Function(
          Offset startPoint, Offset endPoint, double cellSize, double spacing)
      onSetWallTemp;
  final Function resetPoint;

  const BoardInteractionWidget({
    super.key,
    required this.wallTempCoord,
    required this.boardSize,
    required this.boardBoarder,
    required this.cellSize,
    required this.spacing,
    required this.startPoint,
    required this.endPoint,
    required this.onEmptyWallTemp,
    required this.setPoint,
    required this.userWallCount,
    required this.updatePoint,
    required this.onSetPlayer,
    required this.onSetWallTemp,
    required this.resetPoint,
  });

  @override
  BoardInteractionState createState() => BoardInteractionState();
}

class BoardInteractionState extends State<BoardInteractionWidget> {
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
      onTapUp: widget.wallTempCoord.isEmpty
          ? null
          : (details) {
              widget.onEmptyWallTemp();
            },
      onPanStart: widget.wallTempCoord.isEmpty
          ? (details) {
              widget.setPoint(
                  details.localPosition, null);
            }
          : null,
      onPanUpdate: (details) {
        if (widget.startPoint != null &&
            details.localPosition.dx >= 0 &&
            details.localPosition.dx <=
                widget.boardSize - 2 * (widget.spacing + widget.boardBoarder) &&
            details.localPosition.dy >= 0 &&
            details.localPosition.dy <=
                widget.boardSize - 2 * (widget.spacing + widget.boardBoarder) &&
            widget.userWallCount > 0) {
          double distance =
              (widget.startPoint! - details.localPosition).distance;
          widget.updatePoint(distance, details.localPosition);

          // restrictedEnd 계산
          calculateRestrictedEnd(widget.startPoint!, details.localPosition);
        }
      },
      onPanEnd: widget.wallTempCoord.isEmpty
          ? (details) {
              if (widget.startPoint == null) {
                print('startPoint가 null입니다.');
                return;
              }

              if (widget.endPoint == null) {
                widget.onSetPlayer(
                    widget.startPoint!, widget.cellSize, widget.spacing);
              } else if (restrictedEnd != null) {
                widget.onSetWallTemp(widget.startPoint!, restrictedEnd!,
                    widget.cellSize, widget.spacing); // restrictedEnd 사용
              } else {
                print('restrictedEnd가 null입니다.');
              }

              widget.resetPoint();
            }
          : null,
    );
  }
}
