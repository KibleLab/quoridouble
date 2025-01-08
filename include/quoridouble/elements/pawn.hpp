#ifndef QUORIDOUBLE_ELEMENTS_PAWN_HPP_
#define QUORIDOUBLE_ELEMENTS_PAWN_HPP_

#include "quoridouble/elements/board.hpp"
#include <vector>

class Pawn {
private:
  // 기본 이동 (상하좌우)
  static void checkBasicMove(const Board &board, int row, int col,
                             std::vector<std::pair<int, int>> &moves) {
    // 상
    if (canMove(board, row, col, row - 2, col))
      moves.push_back({row - 2, col});

    // 하
    if (canMove(board, row, col, row + 2, col))
      moves.push_back({row + 2, col});

    // 좌
    if (canMove(board, row, col, row, col - 2))
      moves.push_back({row, col - 2});

    // 우
    if (canMove(board, row, col, row, col + 2))
      moves.push_back({row, col + 2});
  }

  // 점프 이동 (상대방 말 넘기)
  static void checkJumpMove(const Board &board, int row, int col,
                            std::vector<std::pair<int, int>> &moves) {
    // 상단 점프
    if (hasOpponent(board, row - 2, col)) {
      if (canJump(board, row, col, row - 2, col, row - 4, col)) {
        moves.push_back({row - 4, col});
      } else {
        // 대각선 이동 체크 (상단 좌우)
        if (canMove(board, row - 2, col, row - 2, col - 2))
          moves.push_back({row - 2, col - 2});
        if (canMove(board, row - 2, col, row - 2, col + 2))
          moves.push_back({row - 2, col + 2});
      }
    }

    // 하단 점프
    if (hasOpponent(board, row + 2, col)) {
      if (canJump(board, row, col, row + 2, col, row + 4, col)) {
        moves.push_back({row + 4, col});
      } else {
        // 대각선 이동 체크 (하단 좌우)
        if (canMove(board, row + 2, col, row + 2, col - 2))
          moves.push_back({row + 2, col - 2});
        if (canMove(board, row + 2, col, row + 2, col + 2))
          moves.push_back({row + 2, col + 2});
      }
    }

    // 좌측 점프
    if (hasOpponent(board, row, col - 2)) {
      if (canJump(board, row, col, row, col - 2, row, col - 4)) {
        moves.push_back({row, col - 4});
      } else {
        // 대각선 이동 체크 (좌측 상하)
        if (canMove(board, row, col - 2, row - 2, col - 2))
          moves.push_back({row - 2, col - 2});
        if (canMove(board, row, col - 2, row + 2, col - 2))
          moves.push_back({row + 2, col - 2});
      }
    }

    // 우측 점프
    if (hasOpponent(board, row, col + 2)) {
      if (canJump(board, row, col, row, col + 2, row, col + 4)) {
        moves.push_back({row, col + 4});
      } else {
        // 대각선 이동 체크 (우측 상하)
        if (canMove(board, row, col + 2, row - 2, col + 2))
          moves.push_back({row - 2, col + 2});
        if (canMove(board, row, col + 2, row + 2, col + 2))
          moves.push_back({row + 2, col + 2});
      }
    }
  }

  // 이동 가능 여부 확인
  static bool canMove(const Board &board, int from_row, int from_col,
                      int to_row, int to_col) {
    // 보드 범위 체크
    if (to_row < 0 || to_row >= board.getBoardSize() || to_col < 0 ||
        to_col >= board.getBoardSize())
      return false;

    // 목적지에 다른 말이 있는지 체크
    if (board.getPosition(to_row, to_col) == 1 ||
        board.getPosition(to_row, to_col) == 2)
      return false;

    // 벽 체크
    if (hasWallBetween(board, from_row, from_col, to_row, to_col))
      return false;

    return true;
  }

  // 두 위치 사이에 벽이 있는지 확인
  static bool hasWallBetween(const Board &board, int from_row, int from_col,
                             int to_row, int to_col) {
    // 가로 이동시 세로벽 체크
    if (from_row == to_row) {
      int wall_col = (from_col + to_col) / 2;
      if (board.getPosition(from_row, wall_col) == 4) {
        return true;
      }
      if (board.getPosition(from_row - 1, wall_col) == 4 ||
          board.getPosition(from_row + 1, wall_col) == 4) {
        return true;
      }
    }

    // 세로 이동시 가로벽 체크
    if (from_col == to_col) {
      int wall_row = (from_row + to_row) / 2;
      if (board.getPosition(wall_row, from_col) == 3) {
        return true;
      }
      if (board.getPosition(wall_row, from_col - 1) == 3 ||
          board.getPosition(wall_row, from_col + 1) == 3) {
        return true;
      }
    }

    // 대각선 이동시 양쪽 벽 체크
    if (from_row != to_row && from_col != to_col) {
      // 수직 이동 후 수평 이동을 한다고 가정했을 때의 벽 체크
      if (hasWallBetween(board, from_row, from_col, to_row, from_col) ||
          hasWallBetween(board, to_row, from_col, to_row, to_col)) {
        return true;
      }

      // 수평 이동 후 수직 이동을 한다고 가정했을 때의 벽 체크
      if (hasWallBetween(board, from_row, from_col, from_row, to_col) ||
          hasWallBetween(board, from_row, to_col, to_row, to_col)) {
        return true;
      }
    }

    return false;
  }

  // 상대방 말이 있는지 확인
  static bool hasOpponent(const Board &board, int row, int col) {
    if (row < 0 || row >= board.getBoardSize() || col < 0 ||
        col >= board.getBoardSize())
      return false;

    int pos = board.getPosition(row, col);
    return pos == 1 || pos == 2; // 1 또는 2는 플레이어 말
  }

  // 점프 가능 여부 확인
  static bool canJump(const Board &board, int from_row, int from_col,
                      int over_row, int over_col, int to_row, int to_col) {
    // 도착 위치가 보드 범위 내인지
    if (to_row < 0 || to_row >= board.getBoardSize() || to_col < 0 ||
        to_col >= board.getBoardSize())
      return false;

    // 도착 위치에 다른 말이 있는지
    if (board.getPosition(to_row, to_col) == 1 ||
        board.getPosition(to_row, to_col) == 2)
      return false;

    // 점프하려는 위치에 벽이 없는지
    if (hasWallBetween(board, from_row, from_col, over_row, over_col) ||
        hasWallBetween(board, over_row, over_col, to_row, to_col))
      return false;

    return true;
  }

public:
  // 주어진 위치에서 가능한 모든 이동 위치 반환
  static std::vector<std::pair<int, int>>
  getPossibleMoves(const Board &board, int curr_row, int curr_col) {
    std::vector<std::pair<int, int>> moves;

    // 상하좌우 이동 확인
    checkBasicMove(board, curr_row, curr_col, moves);

    // 상대방 말 주변 이동 확인
    checkJumpMove(board, curr_row, curr_col, moves);

    return moves;
  }
};

#endif // QUORIDOUBLE_ELEMENTS_PAWN_HPP_