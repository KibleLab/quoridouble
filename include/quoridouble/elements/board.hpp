#ifndef QUORIDOUBLE_ELEMENTS_BOARD_HPP_
#define QUORIDOUBLE_ELEMENTS_BOARD_HPP_

#include <iomanip>
#include <iostream>
#include <vector>

class Board {
private:
  static const int BOARD_SIZE = 17;
  static const int END_ROW_P1 = 0;  // P1의 승리 행 (맨 위)
  static const int END_ROW_P2 = 16; // P2의 승리 행 (맨 아래)

  std::vector<std::vector<int>>
      board; // 0: 빈칸, 1: P1, 2: P2, 3: 가로벽, 4: 세로벽
  std::pair<int, int> p1_pos; // P1의 현재 위치
  std::pair<int, int> p2_pos; // P2의 현재 위치

public:
  Board() : board(BOARD_SIZE, std::vector<int>(BOARD_SIZE, 0)) {
    // 초기 플레이어 위치 설정
    p1_pos = {16, 8}; // P1 시작 위치
    p2_pos = {0, 8};  // P2 시작 위치
    board[p1_pos.first][p1_pos.second] = 1;
    board[p2_pos.first][p2_pos.second] = 2;
  }

  Board clone() const { return *this; }

  std::pair<int, int> getPlayerPosition(int player) const {
    return (player == 1) ? p1_pos : p2_pos;
  }

  void updatePlayerPosition(int player, int row, int col) {
    // 이전 위치의 말 제거
    auto &old_pos = (player == 1) ? p1_pos : p2_pos;
    board[old_pos.first][old_pos.second] = 0;

    // 새 위치에 말 배치
    board[row][col] = player;
    if (player == 1) {
      p1_pos = {row, col};
    } else {
      p2_pos = {row, col};
    }
  }

  bool isWinningPosition(int player) const {
    if (player == 1) {
      return p1_pos.first == END_ROW_P1;
    } else {
      return p2_pos.first == END_ROW_P2;
    }
  }

  bool placePawn(int row, int col, int player) {
    if (row < 0 || row >= BOARD_SIZE || col < 0 || col >= BOARD_SIZE ||
        board[row][col] != 0 || player < 1 || player > 2) {
      return false;
    }
    board[row][col] = player;
    updatePlayerPosition(player, row, col);
    return true;
  }

  // 가로벽 설치: row, col은 벽이 시작되는 위치
  bool placeHorizontalWall(int row, int col) {
    // 벽은 짝수 행에만 설치 가능
    if (row % 2 != 1)
      return false;

    // 범위 체크 (2칸을 차지하므로 col+1도 체크)
    if (row < 0 || row >= BOARD_SIZE || col < 0 || col + 1 >= BOARD_SIZE ||
        board[row][col] != 0 || board[row][col + 1] != 0) {
      return false;
    }

    // 가로벽 2칸 설치
    board[row][col] = 3;
    board[row][col + 1] = 3;
    board[row][col + 2] = 3;
    return true;
  }

  // 세로벽 설치: row, col은 벽이 시작되는 위치
  bool placeVerticalWall(int row, int col) {
    // 벽은 짝수 열에만 설치 가능
    if (col % 2 != 1)
      return false;

    // 범위 체크 (2칸을 차지하므로 row+1도 체크)
    if (row < 0 || row + 1 >= BOARD_SIZE || col < 0 || col >= BOARD_SIZE ||
        board[row][col] != 0 || board[row + 1][col] != 0) {
      return false;
    }

    // 세로벽 2칸 설치
    board[row][col] = 4;
    board[row + 1][col] = 4;
    board[row + 2][col] = 4;
    return true;
  }

  int getPosition(int row, int col) const {
    if (row < 0 || row >= BOARD_SIZE || col < 0 || col >= BOARD_SIZE) {
      return -1;
    }
    return board[row][col];
  }

  void printBoard() const {
    std::cout << "   ";
    for (int i = 0; i < BOARD_SIZE; ++i) {
      std::cout << std::setw(2) << i + 1 << " ";
    }
    std::cout << "\n";

    for (int i = 0; i < BOARD_SIZE; ++i) {
      std::cout << std::setw(2) << i + 1 << " ";
      for (int j = 0; j < BOARD_SIZE; ++j) {
        switch (board[i][j]) {
        case 0:
          std::cout << " · ";
          break;
        case 1:
          std::cout << " 1 ";
          break;
        case 2:
          std::cout << " 2 ";
          break;
        case 3:
          std::cout << " - ";
          break;
        case 4:
          std::cout << " | ";
          break;
        default:
          std::cout << " ? ";
        }
      }
      std::cout << "\n";
    }
  }

  static int getBoardSize() { return BOARD_SIZE; }
};

#endif // QUORIDOUBLE_ELEMENTS_BOARD_HPP_