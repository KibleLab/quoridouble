import 'dart:math';
import 'package:quoridouble/utils/game.dart';

// 최대값의 인덱스를 반환
int argmax(List<dynamic> collection) {
  int maxIndex = 0;
  for (int i = 1; i < collection.length; i++) {
    if (collection[i] > collection[maxIndex]) {
      maxIndex = i;
    }
  }
  return maxIndex;
}

class Node {
  GameState state; // 상태
  double w = 0; // 보상 누계
  int n = 0; // 시행 횟수
  List<Node>? childNodes; // 자녀 노드 리스트

  // 노드 초기화
  Node(this.state);

  // 국면 가치 계산
  double evaluate() {
    // 게임 종료 시
    if (state.isLose()) {
      double value = -100.0;
      w += value;
      n += 1;
      return value;
    }

    // 자녀 노드가 없는 경우
    if (childNodes == null) {
      double value = state.reward();
      w += value;
      n += 1;

      if (n == 100) {
        expand();
      }
      return value;
    } else {
      // 자녀 노드가 있는 경우
      double value = -nextChildNode().evaluate();
      w += value;
      n += 1;
      return value;
    }
  }

  // 자녀 노드 전개
  void expand() {
    List<int> legalActions = state.legalActions();
    childNodes = [];
    for (int action in legalActions) {
      childNodes!.add(Node(state.next(action)));
    }
  }

  // UCB1이 가장 큰 자녀 노드 얻기
  Node nextChildNode() {
    // 시행 횟수가 0인 자녀 노드 반환
    for (Node childNode in childNodes!) {
      if (childNode.n == 0) {
        return childNode;
      }
    }

    // UCB1 계산
    int t = 0;
    for (Node c in childNodes!) {
      t += c.n;
    }
    List<double> ucb1Values = [];
    for (Node childNode in childNodes!) {
      double ucb1 = -childNode.w / childNode.n + sqrt(2 * log(t) / childNode.n);
      ucb1Values.add(ucb1);
    }

    // UCB1이 가장 큰 자녀 노드 반환
    return childNodes![argmax(ucb1Values)];
  }
}

// 몬테카를로 트리 탐색의 행동 선택
int mctsAction(GameState state) {
  // 현재 국면의 루트 노드 생성
  Node rootNode = Node(state);
  rootNode.expand();

  // 시뮬레이션 실행
  for (int i = 0; i < 5000; i++) {
    rootNode.evaluate();
  }

  // 시행 횟수가 가장 큰 값을 갖는 행동 반환
  List<int> legalActions = state.legalActions();
  List<int> nList = [];
  for (Node c in rootNode.childNodes!) {
    nList.add(c.n);
  }
  return legalActions[argmax(nList)];
}
