import 'package:flutter/material.dart';
import 'package:quoridouble/utils/game_state.dart';
import 'package:quoridouble/widgets/board_widgets/board_grid_widget.dart';
import 'package:quoridouble/widgets/board_widgets/board_interaction_widget.dart';
import 'package:quoridouble/widgets/board_widgets/move_button_widget.dart';
import 'package:quoridouble/widgets/board_widgets/pieces_widget.dart';
import 'package:quoridouble/widgets/board_widgets/wall_placement_painter.dart';
import 'package:quoridouble/widgets/board_widgets/wall_temp_widget.dart';
import 'package:quoridouble/widgets/board_widgets/walls_widget.dart';

class QuoridorBoard extends StatelessWidget {
  final double boardSize;
  final GameState gameState;
  final int isFirst;
  final List<int> user1;
  final List<int> user2;
  final List<String> wall;
  final String wallTempCoord;
  final Offset? startPoint;
  final Offset? endPoint;

  final Function emptyTempWall;
  final dynamic setPoint;
  final dynamic onPanUpdate;
  final Function resetPoint;

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
    required this.wall,
    required this.wallTempCoord,
    required this.startPoint,
    required this.endPoint,
    required this.emptyTempWall,
    required this.setPoint,
    required this.onPanUpdate,
    required this.resetPoint,
    required this.onSetPlayer,
    required this.onSetWallTemp,
    required this.onSetWall,
  });

  @override
  Widget build(BuildContext context) {
    double boardBoarder = boardSize * 0.01;
    final double spacing = boardSize * 0.02;
    final double cellSize = (boardSize - 2 * boardBoarder - 10 * spacing) / 9;

    WallPlacementPainter painter =
        WallPlacementPainter(startPoint, endPoint, cellSize, spacing);

    return Container(
      width: boardSize, // 정사각형의 가로 크기
      height: boardSize, // 정사각형의 세로 크기
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
          WallsWidget(wall: wall, cellSize: cellSize, spacing: spacing),
          PiecesWidget(
            user1: user1,
            user2: user2,
            cellSize: cellSize,
            spacing: spacing,
            isFirst: isFirst,
          ),

          // 플레이어 이동 가능 방향을 보여줌
          if (!gameState.isLose() &&
              gameState.isCurrentTurn(isFirst) &&
              wallTempCoord.isEmpty)
            MoveButtonWidget(
              gameState: gameState,
              user1: user1,
              cellSize: cellSize,
              spacing: spacing,
            ),

          // 조건에 따라 GestureDetector 설정
          if (!gameState.isLose() && gameState.isCurrentTurn(isFirst))
            BoardInteractionWidget(
              tempWall: wallTempCoord,
              boardSize: boardSize,
              boardBoarder: boardBoarder,
              spacing: spacing,
              startPoint: startPoint,
              endPoint: endPoint,
              userWallCount: gameState.getUser1WallCount(isFirst),
              emptyTempWall: emptyTempWall,
              setPoint: setPoint,
              onPanUpdate: onPanUpdate,
              setPlayer: onSetPlayer,
              setWallTemp: onSetWallTemp,
              resetPoint: resetPoint,
            ),

          WallTempWidget(
            wallTemp: wallTempCoord,
            cellSize: cellSize,
            spacing: spacing,
            touchMargin: cellSize / 2,
            onSetWall: onSetWall,
          ),
        ],
      ),
    );
  }
}
