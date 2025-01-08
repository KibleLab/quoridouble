#ifndef QUORIDOUBLE_ELEMENTS_WALL_HPP_
#define QUORIDOUBLE_ELEMENTS_WALL_HPP_

#include "quoridouble/elements/board.hpp"
#include "quoridouble/elements/pawn.hpp"
#include <set>
#include <utility>
#include <vector>

class Wall {
private:
  using Position = std::pair<int, int>;

public:
  // 가로벽 배치 가능한 모든 위치 반환
  static std::vector<Position> getPossibleHorizontalWalls(const Board &board) {
    std::vector<Position> positions;
    const int size = board.getBoardSize();

    for (int row = 1; row < size; row += 2) {       // 홀수 행
      for (int col = 0; col < size - 2; col += 2) { // 짝수 열부터 시작
        if (canPlaceHorizontalWall(board, row, col)) {
          positions.push_back({row, col});
        }
      }
    }
    return positions;
  }

  // 세로벽 배치 가능한 모든 위치 반환
  static std::vector<Position> getPossibleVerticalWalls(const Board &board) {
    std::vector<Position> positions;
    const int size = board.getBoardSize();

    for (int row = 0; row < size - 2; row += 2) { // 짝수 행
      for (int col = 1; col < size; col += 2) {   // 홀수 열
        if (canPlaceVerticalWall(board, row, col)) {
          positions.push_back({row, col});
        }
      }
    }
    return positions;
  }

  // 벽 설치 후 양 플레이어의 경로가 존재하는지 확인
  static bool validateWallPlacement(const Board &board, int row, int col,
                                    bool isHorizontal) {
    Board tempBoard = board.clone();

    // 임시로 벽 설치
    bool success = isHorizontal ? tempBoard.placeHorizontalWall(row, col)
                                : tempBoard.placeVerticalWall(row, col);

    if (!success)
      return false;

    // 양 플레이어의 경로 존재 확인
    return hasPathToGoal(tempBoard, 1) && hasPathToGoal(tempBoard, 2);
  }

private:
  // 가로벽 설치 가능 여부 확인
  static bool canPlaceHorizontalWall(const Board &board, int row, int col) {
    // 기본 유효성 검사
    if (row % 2 != 1)
      return false;

    if (row < 0 || row >= board.getBoardSize() || col < 0 ||
        col + 2 >= board.getBoardSize()) {
      return false;
    }

    // 설치 위치 점유 여부 확인
    for (int c = col; c <= col + 2; c++) {
      if (board.getPosition(row, c) != 0)
        return false;
    }

    // 인접한 벽 확인 (수직 교차)
    for (int c = col; c <= col + 2; c++) {
      if ((row > 1 && board.getPosition(row - 1, c) == 4) ||
          (row < board.getBoardSize() - 1 &&
           board.getPosition(row + 1, c) == 4)) {
        return false;
      }
    }

    return true;
  }

  // 세로벽 설치 가능 여부 확인
  static bool canPlaceVerticalWall(const Board &board, int row, int col) {
    // 기본 유효성 검사
    if (col % 2 != 1)
      return false;

    if (row < 0 || row + 2 >= board.getBoardSize() || col < 0 ||
        col >= board.getBoardSize()) {
      return false;
    }

    // 설치 위치 점유 여부 확인
    for (int r = row; r <= row + 2; r++) {
      if (board.getPosition(r, col) != 0)
        return false;
    }

    // 인접한 벽 확인 (수평 교차)
    for (int r = row; r <= row + 2; r++) {
      if ((col > 1 && board.getPosition(r, col - 1) == 3) ||
          (col < board.getBoardSize() - 1 &&
           board.getPosition(r, col + 1) == 3)) {
        return false;
      }
    }

    return true;
  }

  // DFS를 사용하여 목표지점까지의 경로 존재 여부 확인
  static bool hasPathToGoal(const Board &board, int player) {
    const int targetRow = (player == 1) ? 0 : board.getBoardSize() - 1;
    Position start = board.getPlayerPosition(player);

    std::vector<Position> stack; // DFS용 스택
    std::set<Position> visited;

    stack.push_back(start);
    visited.insert(start);

    while (!stack.empty()) {
      Position current = stack.back();
      stack.pop_back();

      // 목표 행에 도달했는지 확인
      if (current.first == targetRow) {
        return true;
      }

      // 가능한 모든 이동 위치 확인
      std::vector<Position> possibleMoves =
          Pawn::getPossibleMoves(board, current.first, current.second);

      // DFS 순서로 처리 (역순으로 스택에 추가)
      for (auto it = possibleMoves.rbegin(); it != possibleMoves.rend(); ++it) {
        if (visited.find(*it) == visited.end()) {
          stack.push_back(*it);
          visited.insert(*it);
        }
      }
    }

    return false;
  }
};

#endif // QUORIDOUBLE_ELEMENTS_WALL_HPP_