// 알파베타법을 활용한 상태 가치 계산
import 'package:quoridouble/utils/AI/index.dart';
import 'package:quoridouble/utils/AI/game_state.dart';

double alphaBeta(GameState state, double alpha, double beta, int depth,
    [int pruningVersion = 0]) {
  // 패배 시, 상태 가치 -100
  if (state.isLose()) {
    return -100;
  }

  if (depth == 0) {
    return state.reward();
  }

  List<int> pruningList = [];
  if (pruningVersion == 1) {
    pruningList = pruningActionVer1(state);
  } else if (pruningVersion == 2) {
    pruningList = pruningActionVer2(state);
  } else {
    pruningList = state.pruningAction();
  }

  for (int action in pruningList) {
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
int alphaBetaAction(GameState state, int depth, {int pruningVersion = 0}) {
  final wallCount = 10 - (state.pieces.where((p) => p == 2).length ~/ 3);

  if (wallCount == 0) {
    int piecesIdx = state.pieces.indexOf(1);
    List<int> p1Pos = [(piecesIdx ~/ 17), (piecesIdx % 17)];

    int enemyIdx = state.enemyPieces.reversed.toList().indexOf(1);
    List<int> p2Pos = [(enemyIdx ~/ 17), (enemyIdx % 17)];

    List<List<int>> dxy = [
      [0, 2],
      [0, -2],
      [-2, 0],
      [2, 0]
    ];

    int deltaX = p2Pos[0] - p1Pos[0];
    int deltaY = p2Pos[1] - p1Pos[1];

    if (!containsList(dxy, [deltaX, deltaY])) {
      return state.findShotPathAction();
    }
  }

  // 합법적인 수의 상태 가치 계산
  int bestAction = 0;
  double alpha = double.negativeInfinity;
  double beta = double.infinity;
  double score = 0.0;

  List<int> pruningList = [];
  if (pruningVersion == 1) {
    pruningList = pruningActionVer1(state);
  } else if (pruningVersion == 2) {
    pruningList = pruningActionVer2(state);
  } else {
    pruningList = state.pruningAction();
  }

  for (int action in pruningList) {
    score =
        -alphaBeta(state.next(action), -beta, -alpha, depth, pruningVersion);
    if (score > alpha) {
      bestAction = action;
      alpha = score;
    }
  }

  // 합법적인 수의 상태 가치값 중 최대값을 선택하는 행동 반환
  return bestAction;
}
