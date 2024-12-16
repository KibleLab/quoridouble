import 'dart:math';

import 'package:quoridouble/utils/AI/alpha_beta.dart';
import 'package:quoridouble/utils/AI/mcts.dart';
import 'package:quoridouble/utils/AI/game_state.dart';

int actionLevel(GameState state, int level) {
  final actions = [
    () => alphaBetaAction(state, 1), // level 0 (default)
    () => alphaBetaAction(state, 1, pruningVersion: 1), // level 1
    () => alphaBetaAction(state, 1, pruningVersion: 2), // level 2
    () => alphaBetaAction(state, 1), // level 3
    () => alphaBetaAction(state, 2), // level 4
    () => mctsAction(state), // level 5
  ];

  // level이 범위를 벗어나면 기본값으로 첫 번째 요소 실행
  return (level >= 0 && level < actions.length)
      ? actions[level]()
      : alphaBetaAction(state, 1);
}

List<int> pruningActionVer1(GameState state) {
  List<int> action = state.legalActions();

  // 0부터 11까지의 숫자를 포함하는 리스트
  List<int> fixedActions1 = action.where((x) => x < 12).toList();

  List<int> shuffleActions = action.where((x) => x >= 12 && x <= 139).toList();

  // shuffle_actions 랜덤하게 선택
  shuffleActions.shuffle();
  List<int> selectedActions =
      shuffleActions.sublist(0, shuffleActions.length ~/ 4);

  // 두 리스트를 합쳐서 반환
  return [...fixedActions1, ...selectedActions];
}

List<int> pruningActionVer2(GameState state) {
  List<int> action = state.legalActions();

  // 0부터 11까지의 숫자를 포함하는 리스트
  List<int> fixedActions1 = action.where((x) => x < 12).toList();

  List<int> shuffleActions = action.where((x) => x >= 12 && x <= 139).toList();

  // shuffle_actions 랜덤하게 선택
  shuffleActions.shuffle();
  List<int> selectedActions =
      shuffleActions.sublist(0, shuffleActions.length ~/ 2);

  // 두 리스트를 합쳐서 반환
  return [...fixedActions1, ...selectedActions];
}

int randomAction(GameState state) {
  List<int> legalActions = state.legalActions();
  return legalActions[Random().nextInt(legalActions.length)];
}

void main() {
  GameState state = GameState();

  while (true) {
    if (state.isDone()) {
      break;
    }

    state = state.next(randomAction(state));

    print('$state\n');
  }
}
