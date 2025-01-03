import 'dart:ui';

import 'package:quoridouble/utils/game_state.dart';

/// ****************************************************************************************
/// 보드판과 gameState 간의 상호작용 함수
/// ****************************************************************************************

List<int> eventToIndex(Offset event, double cellSize, double spacing) {
  double boundary = cellSize + spacing;
  int x = 2 * (event.dx ~/ boundary); // 가로
  int y = 2 * (event.dy ~/ boundary); // 세로

  if (boundary * ((event.dx ~/ boundary) + 1) - event.dx < spacing) {
    x += 1; // 가로
  }

  if (boundary * ((event.dy ~/ boundary) + 1) - event.dy < spacing) {
    y += 1; // 세로
  }

  return [x, y];
}

Map<String, dynamic> setPlayer(Offset event, double cellSize, double spacing,
    List<int> user1, int isFirst, GameState gameState) {
  // 클릭 위치를 행동으로 변환
  List<int> pos = eventToIndex(event, cellSize, spacing);

  List legalMove = gameState.legalMoves();

  List<int> target = [pos[1] - (user1[0] * 2), pos[0] - (user1[1] * 2)];

  bool exists = legalMove
      .any((element) => element[0] == target[0] && element[1] == target[1]);

  int? action;

  if (exists) {
    List<List<int>> moves = [
      [-2, 0], // N (인덱스 0)
      [-2, 2], // NE (인덱스 1)
      [0, 2], // E (인덱스 2)
      [2, 2], // SE (인덱스 3)
      [2, 0], // S (인덱스 4)
      [2, -2], // SW (인덱스 5)
      [0, -2], // W (인덱스 6)
      [-2, -2], // NW (인덱스 7)
      [-4, 0], // NN (인덱스 8)
      [0, 4], // EE (인덱스 9)
      [4, 0], // SS (인덱스 10)
      [0, -4], // WW (인덱스 11)
    ];

    int? findIndex(List<List<int>> moves, List<int> target) {
      for (int i = 0; i < moves.length; i++) {
        if (moves[i][0] == target[0] && moves[i][1] == target[1]) {
          return i;
        }
      }
      return null; // 찾지 못한 경우
    }

    action = findIndex(moves, target);

    gameState = gameState.next(action!);
  }

  // gameState, user1, user2를 Map으로 반환
  return {
    'gameState': gameState,
    'action': action,
    'user1': gameState.user1Pos(isFirst),
    'user2': gameState.user2Pos(isFirst),
  };
}

int locationToWallIndex(double location, double cellSize, double spacing) {
  double padding = cellSize / 2;
  int index = 0;

  for (int i = 1; i <= 8; i++) {
    if (i * cellSize + (i - 1) * spacing - padding <= location &&
        location <= i * (cellSize + spacing) + padding) {
      index = i;
    }
  }

  return index;
}

int locationToWallOtherIndex(double location, double cellSize, double spacing) {
  int index = 0;

  for (int i = 1; i <= 9; i++) {
    if ((i - 1) * (cellSize + spacing) <= location &&
        location <= (i - 1) * (cellSize + spacing) + cellSize) {
      index = i;
    }
  }

  return index;
}

String setWallTemp(Offset start, Offset end, double cellSize, double spacing,
    GameState gameState) {
  String wallTemp = ''; // 초기화

  // 두 점 사이의 거리 계산
  double distance = (start - end).distance;

  // 길이가 일정이상 이여야 동작함.
  if (distance >= cellSize + spacing) {
    // 세로 직선
    if (start.dx == end.dx) {
      int wallIndex = locationToWallIndex(start.dx, cellSize, spacing);

      // X가 범위내에 들어와 있는지 확인
      if (wallIndex != 0) {
        String col = String.fromCharCode(64 + wallIndex);

        if (start.dy > end.dy) {
          int wallOtherIndex =
              locationToWallOtherIndex(start.dy - spacing, cellSize, spacing);
          String row = (wallOtherIndex - 1).toString();

          if (wallOtherIndex != 0) {
            int action = gameState.xyToWallAction(
                2 * (wallOtherIndex - 2), 2 * wallIndex - 1);

            if (gameState.legalActions().contains(action)) {
              wallTemp = col + row;
            }
          }
        } else if (start.dy < end.dy) {
          int wallOtherIndex =
              locationToWallOtherIndex(start.dy + spacing, cellSize, spacing);
          String row = wallOtherIndex.toString();

          if (wallOtherIndex != 0) {
            int action = gameState.xyToWallAction(
                2 * (wallOtherIndex - 1), 2 * wallIndex - 1);

            if (gameState.legalActions().contains(action)) {
              wallTemp = col + row;
            }
          }
        }
      }
    }

    // 가로 직선
    if (start.dy == end.dy) {
      int wallIndex = locationToWallIndex(start.dy, cellSize, spacing);

      // Y가 범위내에 들어와 있는지 확인
      if (wallIndex != 0) {
        String row = wallIndex.toString();

        if (start.dx > end.dx) {
          int wallOtherIndex =
              locationToWallOtherIndex(start.dx - spacing, cellSize, spacing);
          String col = String.fromCharCode(64 + wallOtherIndex - 1);

          if (wallOtherIndex != 0) {
            int action = gameState.xyToWallAction(
                2 * wallIndex - 1, 2 * (wallOtherIndex - 2));

            if (gameState.legalActions().contains(action)) {
              wallTemp = row + col;
            }
          }
        } else if (start.dx < end.dx) {
          int wallOtherIndex =
              locationToWallOtherIndex(start.dx + spacing, cellSize, spacing);
          String col = String.fromCharCode(64 + wallOtherIndex);

          if (wallOtherIndex != 0) {
            int action = gameState.xyToWallAction(
                2 * wallIndex - 1, 2 * (wallOtherIndex - 1));

            if (gameState.legalActions().contains(action)) {
              wallTemp = row + col;
            }
          }
        }
      }
    }
  }

  return wallTemp; // 반환값으로 wallTemp 전달
}

Map<String, dynamic> setWall(
    String wallTemp, List<String> wall, GameState gameState) {
  if (wallTemp.isNotEmpty) {
    bool isNumber = wallTemp[0].contains(RegExp(r'[0-9]'));

    int x = isNumber
        ? 2 * int.parse(wallTemp[0]) - 1
        : 2 * (int.parse(wallTemp[1]) - 1);

    int y = isNumber
        ? 2 * (wallTemp[1].codeUnitAt(0) - 'A'.codeUnitAt(0))
        : 2 * (wallTemp[0].codeUnitAt(0) - 'A'.codeUnitAt(0)) + 1;

    int action = gameState.xyToWallAction(x, y);

    gameState = gameState.next(action);
    wall.add(wallTemp);

    return {
      'gameState': gameState,
      'action': action,
      'wallTemp': '',
    };
  }

  return {
    'gameState': gameState,
    'wallTemp': '',
  };
}
