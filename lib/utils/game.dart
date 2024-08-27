import 'dart:math';
import 'package:pathfinding/core/grid.dart';
import 'package:pathfinding/core/util.dart';
import 'package:pathfinding/finders/jps.dart';

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

  // x y 위치를 입력하면 1차원 보드판 인덱스로 반환
  int _convertXY(int x, int y) {
    return x * 17 + y;
  }

  List<List<int>> _convertBoard() {
    const int wall = -1;
    List<List<int>> board = List.generate(17, (_) => List.filled(17, 0));

    for (int x = 0; x < 17; x++) {
      for (int y = 0; y < 17; y++) {
        int index = _convertXY(x, y);
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

  int _xyToWallAction(int x, int y) {
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

  // 합법적인 수의 리스트 얻기
  List<int> legalActions() {
    const wall = -1;
    final Set<int> actions = {};
    final board = _convertBoard();

    // 플레이어 1의 현재 위치
    final pos = [
      for (int i = 0; i < 17; i++)
        for (int j = 0; j < 17; j++)
          if (board[i][j] == 1) [i, j]
    ][0];

    final east = pos[1] + 2;
    final eeast = pos[1] + 4;
    final west = pos[1] - 2;
    final wwest = pos[1] - 4;
    final north = pos[0] - 2;
    final nnorth = pos[0] - 4;
    final south = pos[0] + 2;
    final ssouth = pos[0] + 4;

    const N = 0;
    const ne = 1;
    const E = 2;
    const se = 3;
    const S = 4;
    const sw = 5;
    const W = 6;
    const nw = 7;
    const nn = 8;
    const ee = 9;
    const ss = 10;
    const ww = 11;

    final dxy = [
      [0, 2],
      [0, -2],
      [-2, 0],
      [2, 0],
    ];

    final conditions = [
      [
        [east, 16, 0, 1],
        [0, west, 0, -1],
        [0, north, -1, 0],
        [south, 16, 1, 0],
      ],
      [
        [eeast, 16, 0, 3],
        [0, wwest, 0, -3],
        [0, nnorth, -3, 0],
        [ssouth, 16, 3, 0],
      ],
      [
        [0, -1, 2],
        [0, -1, -2],
        [1, -2, -1],
        [1, 2, -1],
      ],
      [
        [0, 1, 2],
        [0, 1, -2],
        [1, -2, 1],
        [1, 2, 1],
      ],
    ];

    final direction = [
      [E, W, N, S],
      [ee, ww, nn, ss],
      [ne, nw, nw, sw],
      [se, sw, ne, se],
    ];

    for (int i = 0; i < 4; i++) {
      // 도착지가 보드를 이탈하지 않고 이동경로에 벽이 없을 때
      if (conditions[0][i][0] <= conditions[0][i][1] &&
          board[pos[0] + conditions[0][i][2]][pos[1] + conditions[0][i][3]] !=
              wall) {
        // 도착지(dxy)로 이동
        if (board[pos[0] + dxy[i][0]][pos[1] + dxy[i][1]] == 0) {
          actions.add(direction[0][i]);
        } else if (conditions[1][i][0] <= conditions[1][i][1] &&
            board[pos[0] + conditions[1][i][2]][pos[1] + conditions[1][i][3]] !=
                wall) {
          // 도착지에 플레이어가 있을 때
          // 해당 방향으로 두칸 이동 (도착지가 보드를 이탈하지 않고 이동경로에 벽에 없을 때)
          actions.add(direction[1][i]);
        } else {
          // 대각선 이동1 (도착지가 보드를 이탈하지 않고 이동경로에 벽이 없을 때)
          if (pos[conditions[2][i][0]] - 2 >= 0 &&
              board[pos[0] + conditions[2][i][1]]
                      [pos[1] + conditions[2][i][2]] !=
                  wall) {
            actions.add(direction[2][i]);
          }
          // 대각선 이동2 (도착지가 보드를 이탈하지 않고 이동경로에 벽이 없을 때)
          if (pos[conditions[3][i][0]] + 2 <= 16 &&
              board[pos[0] + conditions[3][i][1]]
                      [pos[1] + conditions[3][i][2]] !=
                  wall) {
            actions.add(direction[3][i]);
          }
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
                int act = _xyToWallAction(i - 1, j);
                actions.add(act);
              }
            }
            // H(가로) 벽 가능 여부 조사
            if (board[i][j - 1] == 0 && board[i][j + 1] == 0) {
              if (isPathAvailable(board, i, j - 1)) {
                int act = _xyToWallAction(i, j - 1);
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
    List<int> action = legalActions();

    // 0부터 11까지의 숫자를 포함하는 리스트
    List<int> fixedActions1 = action.where((x) => x < 12).toList();

    // 76부터 139까지의 숫자를 포함하는 리스트
    List<int> fixedActions2 = action.where((x) => x >= 76).toList();

    List<int> shuffleActions = action.where((x) => x >= 12 && x <= 75).toList();

    // shuffle_actions 절반 랜덤하게 선택
    shuffleActions.shuffle();
    List<int> selectedActions =
        shuffleActions.sublist(0, shuffleActions.length ~/ 2);

    // 두 리스트를 합쳐서 반환
    return [...fixedActions1, ...fixedActions2, ...selectedActions];
  }

  double reward() {
    List<List<int>> board = _convertBoard();
    List<List<dynamic>> mat = board.map((item) => List.from(item)).toList();
    int wall = -1;

    // 플레이어가 이동할 수 없는 교차로 구간 막기
    for (int i = 1; i < mat.length; i += 2) {
      for (int j = 1; j < mat[mat.length - 1].length; j += 2) {
        mat[i][j] = wall;
      }
    }

    // 플레이어 1 플레이어 2 위치 구하기
    List<int> p1Pos = [];
    List<int> p2Pos = [];
    for (int i = 0; i < 17; i++) {
      for (int j = 0; j < 17; j++) {
        if (mat[i][j] == 1) p1Pos = [i, j];
        if (mat[i][j] == 2) p2Pos = [i, j];
      }
    }

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
    List<List<int>> mat = List.generate(
      board.length,
      (i) => List.from(board[i]),
    );

    // 벽 2개 나란히 세웠을 때 틈새 막기
    for (int i = 1; i < mat.length; i += 2) {
      for (int j = 1; j < mat[mat.length - 1].length; j += 2) {
        mat[i][j] = wall;
      }
    }

    // mat에 벽 설치 해보기
    mat[actX][actY] = wall;
    mat[actX + (actX % 2 == 0 ? 2 : 0)][actY + (actX % 2 != 0 ? 2 : 0)] = wall;

    List<int> p1Pos = [];
    List<int> p2Pos = [];
    for (int i = 0; i < 17; i++) {
      for (int j = 0; j < 17; j++) {
        if (mat[i][j] == 1) p1Pos = [i, j];
        if (mat[i][j] == 2) p2Pos = [i, j];
      }
    }

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
      Grid grid = Grid(17, 17, mat);
      List<dynamic> path =
          JumpPointFinder().findPath(p1Pos[1], p1Pos[0], endArray[i], 0, grid);

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
      Grid grid = Grid(17, 17, mat);
      List<dynamic> path =
          JumpPointFinder().findPath(p2Pos[1], p2Pos[0], endArray[i], 16, grid);

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
      // H(가로)의 벽
      if (action > 75) {
        action -= 75;
        x = (action % 8 != 0) ? 2 * (action ~/ 8) + 1 : 2 * (action ~/ 8) - 1;
        y = (action % 8 != 0) ? 2 * (action % 8) - 2 : 14;
        newState.pieces[_convertXY(x, y)] = wall;
        newState.pieces[_convertXY(x, y + 1)] = wall;
        newState.pieces[_convertXY(x, y + 2)] = wall;
      } else {
        // V(세로)의 벽
        action -= 11;
        x = (action % 8 != 0) ? 2 * (action % 8) - 2 : 14;
        y = (action % 8 != 0) ? 2 * (action ~/ 8) + 1 : 2 * (action ~/ 8) - 1;
        newState.pieces[_convertXY(x, y)] = wall;
        newState.pieces[_convertXY(x + 1, y)] = wall;
        newState.pieces[_convertXY(x + 2, y)] = wall;
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

int randomAction(GameState state) {
  List<int> legalActions = state.legalActions();
  return legalActions[Random().nextInt(legalActions.length)];
}

// 알파베타법을 활용한 상태 가치 계산
double alphaBeta(GameState state, double alpha, double beta, int depth) {
  if (depth == 0) {
    return state.reward();
  }

  // 패배 시, 상태 가치 -1000
  if (state.isLose()) {
    return -1000;
  }

  // 무승부 시, 상태 가치 0
  if (state.isDraw()) {
    return 0;
  }

  // 합법적인 수의 상태 가치 계산
  for (int action in state.pruningAction()) {
    double score = -alphaBeta(state.next(action), -beta, -alpha, depth - 1);
    if (score > alpha) {
      alpha = score;
    }

    // 현재 노드의 베스트 스코어가 새로운 노드보다 크면 탐색 종료
    if (alpha >= beta) {
      return alpha;
    }
  }

  // 합법적인 수의 상태 가치의 최대값을 반환
  return alpha;
}

// 알파베타법을 활용한 행동 선택
int alphaBetaAction(GameState state, int depth) {
  // 합법적인 수의 상태 가치 계산
  int bestAction = 0;
  double alpha = double.negativeInfinity;
  double beta = double.infinity;

  for (int action in state.pruningAction()) {
    double score = -alphaBeta(state.next(action), -beta, -alpha, depth);
    if (score > alpha) {
      bestAction = action;
      alpha = score;
    }
  }

  // 합법적인 수의 상태 가치값 중 최대값을 선택하는 행동 반환
  return bestAction;
}

void main() {
  GameState state = GameState();

  while (true) {
    if (state.isDone()) {
      break;
    }

    state = state.next(alphaBetaAction(state, 1));

    print('$state\n');
  }
}
