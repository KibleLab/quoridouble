import 'dart:math';
import 'package:pathfinding/core/grid.dart';
import 'package:pathfinding/core/util.dart';
import 'package:pathfinding/finders/jps.dart';
import 'package:pathfinding/finders/astar.dart';
import 'package:quoridouble/utils/dfs.dart';

bool containsList(List<List<int>> listOfLists, List<int> target) {
  for (List<int> list in listOfLists) {
    if (list.length == target.length &&
        list
            .asMap()
            .entries
            .every((entry) => entry.value == target[entry.key])) {
      return true;
    }
  }
  return false;
}

class GameState {
  List<int> pieces;
  List<int> enemyPieces;
  int depth;

  // 생성자
  GameState({
    List<int>? pieces,
    List<int>? enemyPieces,
    this.depth = 0,
  })  : pieces = pieces ?? List<int>.filled(289, 0),
        enemyPieces = enemyPieces ?? List<int>.filled(289, 0) {
    // 초기 배치
    if (pieces == null || enemyPieces == null) {
      this.pieces[280] = 1;
      this.enemyPieces[280] = 1;
    }
  }

  List<int> user1Pos(int isFirst) {
    List<int> player = depth % 2 == isFirst ? pieces : enemyPieces;
    int pos = player.indexOf(1);
    return [(pos ~/ 17) ~/ 2, (pos % 17) ~/ 2];
  }

  List<int> user2Pos(int isFirst) {
    List<int> player = depth % 2 == isFirst
        ? enemyPieces.reversed.toList()
        : pieces.reversed.toList();
    int pos = player.indexOf(1);
    return [(pos ~/ 17) ~/ 2, (pos % 17) ~/ 2];
  }

  bool isCurrentTurn(int isFirst) {
    return depth % 2 == isFirst;
  }

  int getUser1WallCount(int isFirst) {
    List<int> player = depth % 2 == isFirst ? pieces : enemyPieces;
    // 벽 얼마나 설치 가능한지
    return 10 - (player.where((p) => p == 2).length ~/ 3);
  }

  int getUser2WallCount(int isFirst) {
    List<int> player = depth % 2 == isFirst ? enemyPieces : pieces;
    // 벽 얼마나 설치 가능한지
    return 10 - (player.where((p) => p == 2).length ~/ 3);
  }

  // x y 위치를 입력하면 1차원 보드판 인덱스로 반환
  int convertXY(int x, int y) {
    return x * 17 + y;
  }

  List<List<int>> convertBoard() {
    const int wall = -1;
    List<List<int>> board = List.generate(17, (_) => List.filled(17, 0));

    for (int x = 0; x < 17; x++) {
      for (int y = 0; y < 17; y++) {
        int index = convertXY(x, y);
        int piece = pieces[index];
        int enemyPiece = enemyPieces[288 - index];

        if (piece == 1) {
          board[x][y] = 1;
        } else if (enemyPiece == 1) {
          board[x][y] = 2;
        } else if (piece == 2 || enemyPiece == 2) {
          board[x][y] = wall;
        }
      }
    }

    return board;
  }

  int xyToWallAction(int x, int y) {
    int action;

    // 세로
    if (x % 2 == 0 && y % 2 == 1) {
      action = (x ~/ 2) + 1 + 8 * ((y - 1) ~/ 2) + 11;
    }
    // 가로
    else if (x % 2 == 1 && y % 2 == 0) {
      action = (y ~/ 2) + 1 + 8 * ((x - 1) ~/ 2) + 11 + 64;
    } else {
      throw ArgumentError('Invalid x and y combination');
    }

    return action;
  }

  // 패배 여부 판정
  bool isLose() {
    return List.generate(9, (index) => index * 2)
        .any((line) => enemyPieces[line] == 1);
  }

  // 무승부 여부 판정
  bool isDraw() {
    return depth >= 200;
  }

  // 게임 종료 여부 판정
  bool isDone() {
    return isLose() || isDraw();
  }

  // 선 수 여부 판정
  bool isFirstPlayer() {
    return depth % 2 == 0;
  }

  // 듀얼 네트워크 입력 배열 얻기
  List<List<List<int>>> piecesArray() {
    // 플레이어 별 듀얼 네트워크 입력 배열 얻기
    List<List<int>> piecesArrayOf(List<int> pieces) {
      List<int> table1 = List.filled(289, 0);
      List<int> table2 = List.filled(289, 0);

      for (int i = 0; i < 289; i++) {
        if (pieces[i] == 1) {
          table1[i] = 1;
        } else if (pieces[i] == 2) {
          table2[i] = 1;
        }
      }

      return [table1, table2];
    }

    return [piecesArrayOf(pieces), piecesArrayOf(enemyPieces)];
  }

  List<List<int>> legalMoves() {
    bool isOutOfBounds(int x, int y) {
      return !(0 <= x && x < 17 && 0 <= y && y < 17);
    }

    bool isWall(int x, int y) {
      int index = convertXY(x, y);
      int piece = pieces[index];
      int enemyPiece = enemyPieces.reversed.toList()[index];
      return piece == 2 || enemyPiece == 2;
    }

    bool isInvalidPosition(int x, int y) {
      return isOutOfBounds(x, y) || isWall(x, y);
    }

    int piecesIdx = pieces.indexOf(1);
    List<int> p1Pos = [(piecesIdx ~/ 17), (piecesIdx % 17)];

    int enemyIdx = enemyPieces.reversed.toList().indexOf(1);
    List<int> p2Pos = [(enemyIdx ~/ 17), (enemyIdx % 17)];

    List<List<int>> dxy = [
      [0, 2],
      [0, -2],
      [-2, 0],
      [2, 0]
    ];

    // 플레이어 1이 이동할 수 없는 방향을 제거
    dxy.removeWhere((direction) {
      int newX = p1Pos[0] + direction[0] ~/ 2;
      int newY = p1Pos[1] + direction[1] ~/ 2;
      return isInvalidPosition(newX, newY);
    });

    int deltaX = p2Pos[0] - p1Pos[0];
    int deltaY = p2Pos[1] - p1Pos[1];

    if (!containsList(dxy, [deltaX, deltaY])) {
      return dxy;
    } else {
      dxy.removeWhere(
          (element) => element[0] == deltaX && element[1] == deltaY);

      int checkX = p2Pos[0] + deltaX ~/ 2;
      int checkY = p2Pos[1] + deltaY ~/ 2;

      // 조회한 위치가 보드 범위를 벗어나거나, 벽인지 확인
      if (!isInvalidPosition(checkX, checkY)) {
        dxy.add([deltaX * 2, deltaY * 2]);
        return dxy;
      } else {
        int dX = deltaX == 0 ? -1 : 0;
        int dY = deltaY == 0 ? -1 : 0;

        for (int i = 1; i < 3; i++) {
          checkX = p2Pos[0] + pow(dX, i).toInt();
          checkY = p2Pos[1] + pow(dY, i).toInt();

          if (!isInvalidPosition(checkX, checkY)) {
            dxy.add([
              deltaX + pow(dX, i).toInt() * 2,
              deltaY + pow(dY, i).toInt() * 2
            ]);
          }
        }

        return dxy;
      }
    }
  }

  // 합법적인 수의 리스트 얻기
  List<int> legalActions() {
    final Set<int> actions = {};
    final board = convertBoard();

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

    for (List<int> target in legalMoves()) {
      for (int k = 0; k < moves.length; k++) {
        if (moves[k][0] == target[0] && moves[k][1] == target[1]) {
          actions.add(k);
          break;
        }
      }
    }

    // 벽 얼마나 설치 가능한지
    final wallCount = 10 - (pieces.where((p) => p == 2).length ~/ 3);

    // 벽 사용가능 여부
    if (wallCount > 0) {
      for (int i = 1; i < board.length; i += 2) {
        for (int j = 1; j < board[i].length; j += 2) {
          // 벽 설치 가능한 부분 조사
          if (board[i][j] == 0) {
            // V(세로) 벽 가능 여부 조사
            if (board[i - 1][j] == 0 && board[i + 1][j] == 0) {
              if (isPathAvailable(board, i - 1, j)) {
                int act = xyToWallAction(i - 1, j);
                actions.add(act);
              }
            }
            // H(가로) 벽 가능 여부 조사
            if (board[i][j - 1] == 0 && board[i][j + 1] == 0) {
              if (isPathAvailable(board, i, j - 1)) {
                int act = xyToWallAction(i, j - 1);
                actions.add(act);
              }
            }
          }
        }
      }
    }

    return actions.toList()..sort();
  }

  List<int> pruningAction() {
    final Set<int> actions = {};
    final board = convertBoard();

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

    for (List<int> target in legalMoves()) {
      for (int k = 0; k < moves.length; k++) {
        if (moves[k][0] == target[0] && moves[k][1] == target[1]) {
          actions.add(k);
          break;
        }
      }
    }

    // 벽 얼마나 설치 가능한지
    final wallCount = 10 - (pieces.where((p) => p == 2).length ~/ 3);

    // 벽 사용가능 여부
    if (wallCount > 0) {
      /// ********************************************
      /// candidateActs
      /// ********************************************

      void addCandidateActions(Set<int> candidateActs, int x, int y) {
        // 세로 방향으로 좌표 추가
        List<List<int>> verticalOffsets = [
          [-1, 0],
          [1, 0],
          [-1, -2],
          [1, -2],
          [-3, 0],
          [3, 0],
          [-3, -2],
          [3, -2]
        ];

        // 가로 방향으로 좌표 추가
        List<List<int>> horizontalOffsets = [
          [0, -1],
          [0, 1],
          [-2, -1],
          [-2, 1],
          [0, -3],
          [0, 3],
          [-2, -3],
          [-2, 3]
        ];

        // 세로 및 가로 추가
        for (List<int> offset in verticalOffsets) {
          candidateActs.add(xyToWallAction(x + offset[0], y + offset[1]));
        }
        for (List<int> offset in horizontalOffsets) {
          candidateActs.add(xyToWallAction(x + offset[0], y + offset[1]));
        }
      }

      final Set<int> candidateActs = {};

      // pieces의 좌표에 대해 후보 행동 추가
      int piecesIdx = pieces.indexOf(1);
      int x = piecesIdx ~/ 17;
      int y = piecesIdx % 17;

      final enemyWall = 10 - (enemyPieces.where((p) => p == 2).length ~/ 3);
      if (enemyWall != 0) {
        addCandidateActions(candidateActs, x, y);
      }

      // enemyPieces의 좌표에 대해 후보 행동 추가
      int enemyIdx = enemyPieces.reversed.toList().indexOf(1);
      x = enemyIdx ~/ 17;
      y = enemyIdx % 17;
      addCandidateActions(candidateActs, x, y);

      for (int i = 1; i < board.length; i += 2) {
        for (int j = 1; j < board[i].length; j += 2) {
          // 벽 설치 되어있는 곳 근처에 대해 후보 행동 추가
          if (board[i][j] == 1) {
            // 근처 테두리를 후보에 넣음
            candidateActs.add(xyToWallAction(j - 1, i - 2));
            candidateActs.add(xyToWallAction(j - 1, i + 2));
            candidateActs.add(xyToWallAction(j - 2, i - 1));
            candidateActs.add(xyToWallAction(j + 2, i - 1));

            // 가로로 설치하면 인근 세로를 후보에 넣음
            // 세로로 설치하면 인근 가로를 후보에 넣음
            candidateActs.add(xyToWallAction(j - 3, i));
            candidateActs.add(xyToWallAction(j + 1, i));
            candidateActs.add(xyToWallAction(j, i - 3));
            candidateActs.add(xyToWallAction(j, i + 1));

            // 가로 기준 다음 칸
            candidateActs.add(xyToWallAction(j + 3, i));
            candidateActs.add(xyToWallAction(j - 3, i));
            candidateActs.add(xyToWallAction(j + 4, i - 1));
            candidateActs.add(xyToWallAction(j - 4, i - 1));

            // 세로 기준 다음 칸
            candidateActs.add(xyToWallAction(j, i - 3));
            candidateActs.add(xyToWallAction(j, i + 3));
            candidateActs.add(xyToWallAction(j - 1, i - 4));
            candidateActs.add(xyToWallAction(j - 1, i + 4));

            // 가로 기준 코너
            candidateActs.add(xyToWallAction(j - 2, i - 3));
            candidateActs.add(xyToWallAction(j - 2, i + 1));
            candidateActs.add(xyToWallAction(j + 2, i - 3));
            candidateActs.add(xyToWallAction(j + 2, i + 1));

            // 세로 기준 코너
            candidateActs.add(xyToWallAction(j + 1, i - 2));
            candidateActs.add(xyToWallAction(j - 3, i - 2));
            candidateActs.add(xyToWallAction(j + 1, i + 2));
            candidateActs.add(xyToWallAction(j - 3, i + 2));
          }
        }
      }

      // 상대쪽 수평벽
      for (int i = 76; i <= 83; i++) {
        candidateActs.add(i);
      }

      // 자신쪽 수평벽
      for (int i = 132; i <= 139; i++) {
        candidateActs.add(i);
      }

      /// ********************************************

      for (int i = 1; i < board.length; i += 2) {
        for (int j = 1; j < board[i].length; j += 2) {
          // 벽 설치 가능한 부분 조사
          if (board[i][j] == 0) {
            // V(세로) 벽 가능 여부 조사
            if (board[i - 1][j] == 0 && board[i + 1][j] == 0) {
              int act = xyToWallAction(i - 1, j);

              if (candidateActs.contains(act)) {
                if (isPathAvailable(board, i - 1, j)) {
                  actions.add(act);
                }
              }
            }
            // H(가로) 벽 가능 여부 조사
            if (board[i][j - 1] == 0 && board[i][j + 1] == 0) {
              int act = xyToWallAction(i, j - 1);

              if (candidateActs.contains(act)) {
                if (isPathAvailable(board, i, j - 1)) {
                  actions.add(act);
                }
              }
            }
          }
        }
      }
    }

    return actions.toList()..sort();
  }

  int findShotPathAction() {
    List<List<int>> board = convertBoard();
    List<List<int>> mat = board.map((item) => List<int>.from(item)).toList();
    int wall = -1;

    // 플레이어가 이동할 수 없는 교차로 구간 막기
    for (int i = 1; i < mat.length; i += 2) {
      for (int j = 1; j < mat[mat.length - 1].length; j += 2) {
        mat[i][j] = wall;
      }
    }

    int piecesIdx = pieces.indexOf(1);
    List p1Pos = [(piecesIdx ~/ 17), (piecesIdx % 17)];

    int enemyIdx = enemyPieces.reversed.toList().indexOf(1);
    List p2Pos = [(enemyIdx ~/ 17), (enemyIdx % 17)];

    // mat에 표시되어 있는 플레이어 제거
    mat[p1Pos[0]][p1Pos[1]] = 0;
    mat[p2Pos[0]][p2Pos[1]] = 0;

    // pathfinding 패키지를 위해 -1을 1로 변환
    for (int i = 0; i < mat.length; i++) {
      for (int j = 0; j < mat[i].length; j++) {
        if (mat[i][j] == -1) {
          mat[i][j] = 1;
        }
      }
    }

    List<int> endArray = List.generate(9, (index) => index * 2);
    List<int> pathLenArray = List.filled(9, 0);

    // 각 목표당 걸리는 거리 측정
    for (int i = 0; i < endArray.length; i++) {
      Grid grid = Grid(17, 17, mat);
      List<dynamic> path =
          AStarFinder().findPath(p1Pos[1], p1Pos[0], endArray[i], 0, grid);

      pathLenArray[i] = path.length ~/ 2;
    }

    int minIndex = -1;
    int minValue = double.maxFinite.toInt(); // 매우 큰 값으로 초기화

    for (int i = 0; i < pathLenArray.length; i++) {
      if (pathLenArray[i] != 0 && pathLenArray[i] < minValue) {
        minValue = pathLenArray[i];
        minIndex = i;
      }
    }

    Grid grid = Grid(17, 17, mat);
    List<dynamic> path =
        AStarFinder().findPath(p1Pos[1], p1Pos[0], endArray[minIndex], 0, grid);

    int dx = path[2][0] - path[0][0];
    int dy = path[2][1] - path[0][1];

    List<List<int>> moves = [
      [-2, 0], // N (action 0)
      [0, 2], // E (action 2)
      [2, 0], // S (action 4)
      [0, -2], // W (action 6)
    ];

    for (int i = 0; i < moves.length; i++) {
      if (moves[i][0] == dy && moves[i][1] == dx) {
        return i * 2;
      }
    }

    return -1;
  }

  double reward() {
    List<List<int>> board = convertBoard();
    List<List<int>> mat = board.map((item) => List<int>.from(item)).toList();
    int wall = -1;

    // 플레이어가 이동할 수 없는 교차로 구간 막기
    for (int i = 1; i < mat.length; i += 2) {
      for (int j = 1; j < mat[mat.length - 1].length; j += 2) {
        mat[i][j] = wall;
      }
    }

    int piecesIdx = pieces.indexOf(1);
    List p1Pos = [(piecesIdx ~/ 17), (piecesIdx % 17)];

    int enemyIdx = enemyPieces.reversed.toList().indexOf(1);
    List p2Pos = [(enemyIdx ~/ 17), (enemyIdx % 17)];

    // mat에 표시되어 있는 플레이어 제거
    mat[p1Pos[0]][p1Pos[1]] = 0;
    mat[p2Pos[0]][p2Pos[1]] = 0;

    // pathfinding 패키지를 위해 -1을 1로 변환
    for (int i = 0; i < mat.length; i++) {
      for (int j = 0; j < mat[i].length; j++) {
        if (mat[i][j] == -1) {
          mat[i][j] = 1;
        }
      }
    }

    List<int> endArray = List.generate(9, (index) => index * 2);
    List<int> p1PathLenArray = List.filled(9, 0);
    List<int> p2PathLenArray = List.filled(9, 0);

    // 각 목표당 걸리는 거리 측정
    for (int i = 0; i < endArray.length; i++) {
      Grid grid = Grid(17, 17, mat);
      List<dynamic> path =
          JumpPointFinder().findPath(p1Pos[1], p1Pos[0], endArray[i], 0, grid);

      for (int k = 1; k < path.length; k++) {
        List<dynamic> prev = path[k - 1];
        List<dynamic> curr = path[k];

        p1PathLenArray[i] +=
            abs(curr[0] - prev[0]).toInt() + abs(curr[1] - prev[1]).toInt();
      }

      p1PathLenArray[i] ~/= 2;
    }

    // 각 목표당 걸리는 거리 측정
    for (int i = 0; i < endArray.length; i++) {
      Grid grid = Grid(17, 17, mat);
      List<dynamic> path =
          JumpPointFinder().findPath(p2Pos[1], p2Pos[0], endArray[i], 16, grid);

      for (int k = 1; k < path.length; k++) {
        List<dynamic> prev = path[k - 1];
        List<dynamic> curr = path[k];

        p2PathLenArray[i] +=
            abs(curr[0] - prev[0]).toInt() + abs(curr[1] - prev[1]).toInt();
      }

      p2PathLenArray[i] ~/= 2;
    }

    // 0 이하를 제외한 새로운 배열 생성
    List<int> p1NonZero = p1PathLenArray.where((number) => number > 0).toList();
    List<int> p2NonZero = p2PathLenArray.where((number) => number > 0).toList();

    // 가장 낮은 값 찾기
    // 원래는 조건 설정 안해도 됌. 혹시 모를 예외처리임
    int minP1 =
        p1NonZero.isNotEmpty ? p1NonZero.reduce((a, b) => a < b ? a : b) : 0;
    int minP2 =
        p2NonZero.isNotEmpty ? p2NonZero.reduce((a, b) => a < b ? a : b) : 0;

    // 두 값의 차이 계산
    int difference = minP2 - minP1;

    return difference.toDouble();
  }

  bool isPathAvailable(List<List<int>> board, int actX, int actY) {
    const int wall = -1;
    List<List<int>> mat = board.map((item) => List<int>.from(item)).toList();

    // 벽 2개 나란히 세웠을 때 틈새 막기
    for (int i = 1; i < mat.length; i += 2) {
      for (int j = 1; j < mat[mat.length - 1].length; j += 2) {
        mat[i][j] = wall;
      }
    }

    // mat에 벽 설치 해보기
    mat[actX][actY] = wall;
    mat[actX + (actX % 2 == 0 ? 2 : 0)][actY + (actX % 2 != 0 ? 2 : 0)] = wall;

    int piecesIdx = pieces.indexOf(1);
    List p1Pos = [(piecesIdx ~/ 17), (piecesIdx % 17)];

    int enemyIdx = enemyPieces.reversed.toList().indexOf(1);
    List p2Pos = [(enemyIdx ~/ 17), (enemyIdx % 17)];

    // mat에 표시되어 있는 플레이어 제거
    mat[p1Pos[0]][p1Pos[1]] = 0;
    mat[p2Pos[0]][p2Pos[1]] = 0;

    // pathfinding 패키지를 위해 -1을 1로 변환
    for (int i = 0; i < mat.length; i++) {
      for (int j = 0; j < mat[i].length; j++) {
        if (mat[i][j] == -1) {
          mat[i][j] = 1;
        }
      }
    }

    List<int> endArray = List.generate(9, (index) => index * 2);
    bool p1Path = false;
    bool p2Path = false;

    for (int i = 0; i < endArray.length; i++) {
      DFSPathFinder dfsFinder = DFSPathFinder(mat);
      List<dynamic> path =
          dfsFinder.findPath(p1Pos[1], p1Pos[0], endArray[i], 0);

      if (path.isNotEmpty) {
        p1Path = true;
        break;
      }
    }

    // p1이 길을 못 찾으면 종료
    if (!p1Path) {
      return false;
    }

    for (int i = 0; i < endArray.length; i++) {
      DFSPathFinder dfsFinder = DFSPathFinder(mat);
      List<dynamic> path =
          dfsFinder.findPath(p2Pos[1], p2Pos[0], endArray[i], 16);

      if (path.isNotEmpty) {
        p2Path = true;
        break;
      }
    }

    // 길을 막지 않으면 true
    return p1Path && p2Path;
  }

  // 다음 상태를 반환하는 메서드
  GameState next(int action) {
    GameState newState = GameState(
      pieces: List.from(pieces),
      enemyPieces: List.from(enemyPieces),
      depth: depth + 1,
    );

    int player = 1;
    int wall = 2;

    // 플레이어 위치 구하기
    int pos = pieces.indexOf(player);

    // 방향 정수
    List<int> dxy = [-34, -32, 2, 36, 34, 32, -2, -36, -68, 4, 68, -4];

    // 보드에 플레이어의 선택을 표시
    int x, y;

    if (action >= 0 && action <= 11) {
      newState.pieces[pos] = 0;
      newState.pieces[pos + dxy[action]] = player;
    } else if (action >= 12 && action <= 139) {
      bool isHorizontalWall = action > 75;
      action -= isHorizontalWall ? 75 : 11;

      int quotient = action ~/ 8;
      int remainder = action % 8;

      x = 2 * quotient + (remainder != 0 ? 1 : -1);
      y = (remainder != 0) ? 2 * remainder - 2 : 14;

      if (isHorizontalWall) {
        newState.pieces[convertXY(x, y)] = wall;
        newState.pieces[convertXY(x, y + 1)] = wall;
        newState.pieces[convertXY(x, y + 2)] = wall;
      } else {
        int temp = x;
        x = y;
        y = temp;
        newState.pieces[convertXY(x, y)] = wall;
        newState.pieces[convertXY(x + 1, y)] = wall;
        newState.pieces[convertXY(x + 2, y)] = wall;
      }
    }

    // 교환
    List<int> temp = newState.pieces;
    newState.pieces = newState.enemyPieces;
    newState.enemyPieces = temp;

    return newState;
  }

  @override
  String toString() {
    List<int> pieces0 = isFirstPlayer() ? pieces : enemyPieces;
    List<int> pieces1 = isFirstPlayer() ? enemyPieces : pieces;
    List<String> pw0 = ['', '1', 'x'];
    List<String> pw1 = ['', '2', 'x'];

    // 후 수 플레이어가 갖고 있는 벽
    StringBuffer resultStr = StringBuffer();
    resultStr.write('[${10 - pieces1.where((p) => p == 2).length ~/ 3}]\n');

    // 보드
    for (int i = 0; i < 289; i++) {
      if (pieces0[i] != 0) {
        resultStr.write(pw0[pieces0[i]]);
      } else if (pieces1[288 - i] != 0) {
        resultStr.write(pw1[pieces1[288 - i]]);
      } else {
        if (i ~/ 17 % 2 == 1 || i % 2 == 1) {
          resultStr.write(' ');
        } else {
          resultStr.write('\u00B7');
        }
      }
      if (i % 17 == 16) {
        resultStr.write('\n');
      }
    }

    // 선 수 플레이어가 갖고 있는 벽
    resultStr.write('[${10 - pieces0.where((p) => p == 2).length ~/ 3}]\n');
    return resultStr.toString();
  }
}
