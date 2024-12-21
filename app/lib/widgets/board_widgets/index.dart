import 'package:flutter/material.dart';
import 'package:quoridouble/utils/game_state.dart';
import 'package:quoridouble/widgets/board_widgets/board_grid_widget.dart';
import 'package:quoridouble/widgets/board_widgets/board_interaction_widget.dart';
import 'package:quoridouble/widgets/board_widgets/move_button_widget.dart';
import 'package:quoridouble/widgets/board_widgets/pieces_widget.dart';
import 'package:quoridouble/widgets/board_widgets/wall_placement_painter.dart';
import 'package:quoridouble/widgets/board_widgets/wall_temp_widget.dart';
import 'package:quoridouble/widgets/board_widgets/walls_widget.dart';

class QuoridorBoard extends StatefulWidget {
  final double boardSize;
  final GameState gameState;
  final int isFirst;
  final List<int> user1;
  final List<int> user2;
  final List<String> wallCoords;
  final String wallTempCoord;
  final Function onEmptyWallTemp;

  final dynamic onSetPlayer;
  final dynamic onSetWallTemp;
  final VoidCallback onSetWall;

  const QuoridorBoard({
    super.key,
    required this.boardSize,
    required this.gameState,
    required this.isFirst,
    required this.user1,
    required this.user2,
    required this.wallCoords,
    required this.wallTempCoord,
    required this.onEmptyWallTemp,
    required this.onSetPlayer,
    required this.onSetWallTemp,
    required this.onSetWall,
  });

  @override
  QuoridorBoardState createState() => QuoridorBoardState();
}

class QuoridorBoardState extends State<QuoridorBoard> {
  Offset? startPoint;
  Offset? endPoint;

  @override
  void initState() {
    super.initState();
    startPoint = null;
    endPoint = null;
  }

  @override
  Widget build(BuildContext context) {
    double boardBoarder = widget.boardSize * 0.01;
    final double spacing = widget.boardSize * 0.02;
    final double cellSize =
        (widget.boardSize - 2 * boardBoarder - 10 * spacing) / 9;

    WallPlacementPainter painter =
        WallPlacementPainter(startPoint, endPoint, cellSize, spacing);

    return Container(
      width: widget.boardSize, // 정사각형의 가로 크기
      height: widget.boardSize, // 정사각형의 세로 크기
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color.fromARGB(255, 107, 49, 54), // 테두리 색상
          width: boardBoarder, // 테두리 두께
        ),
        borderRadius: BorderRadius.circular(10.0), // 모서리 둥글기
      ),
      padding: EdgeInsets.all(spacing), // 내부 여백
      child: Stack(
        children: [
          BoardGridWidget(spacing: spacing),
          CustomPaint(painter: painter),
          WallsWidget(wallCoords: widget.wallCoords, cellSize: cellSize, spacing: spacing),
          PiecesWidget(
            user1: widget.user1,
            user2: widget.user2,
            cellSize: cellSize,
            spacing: spacing,
            isFirst: widget.isFirst,
          ),

          // 플레이어 이동 가능 방향을 보여줌
          if (!widget.gameState.isLose() &&
              widget.gameState.isCurrentTurn(widget.isFirst) &&
              widget.wallTempCoord.isEmpty)
            MoveButtonWidget(
              gameState: widget.gameState,
              user1: widget.user1,
              cellSize: cellSize,
              spacing: spacing,
            ),

          // 조건에 따라 GestureDetector 설정
          if (!widget.gameState.isLose() &&
              widget.gameState.isCurrentTurn(widget.isFirst))
            BoardInteractionWidget(
              wallTempCoord: widget.wallTempCoord,
              boardSize: widget.boardSize,
              boardBoarder: boardBoarder,
              spacing: spacing,
              cellSize: cellSize,
              startPoint: startPoint,
              endPoint: endPoint,
              userWallCount: widget.gameState.getUser1WallCount(widget.isFirst),
              onEmptyWallTemp: widget.onEmptyWallTemp,
              onSetPlayer: widget.onSetPlayer,
              onSetWallTemp: widget.onSetWallTemp,
              setPoint: (start, end) {
                setState(() {
                  startPoint = start;
                  endPoint = end;
                });
              },
              updatePoint: (distance, details) => setState(() {
                if (distance > 5) {
                  endPoint = details;
                }
              }),
              resetPoint: () => setState(() {
                startPoint = null;
                endPoint = null;
              }),
            ),

          WallTempWidget(
            wallTemp: widget.wallTempCoord,
            cellSize: cellSize,
            spacing: spacing,
            touchMargin: cellSize / 2,
            onSetWall: widget.onSetWall,
          ),
        ],
      ),
    );
  }
}
