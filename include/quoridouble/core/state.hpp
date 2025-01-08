#ifndef QUORIDOUBLE_CORE_STATE_HPP_
#define QUORIDOUBLE_CORE_STATE_HPP_

#include "quoridouble/core/action.hpp"
#include "quoridouble/elements/board.hpp"
#include "quoridouble/elements/pawn.hpp"
#include "quoridouble/elements/wall.hpp"
#include <vector>

class State {
private:
  Board board;
  int current_player; // 1 또는 2
  int walls_left[2];  // [p1, p2]
  bool game_over;

public:
  State() : current_player(1), game_over(false) {
    walls_left[0] = walls_left[1] = 10; // 각 플레이어 10개의 벽
  }

  State clone() const {
    State new_state;
    new_state.board = board.clone();
    new_state.current_player = current_player;
    new_state.walls_left[0] = walls_left[0];
    new_state.walls_left[1] = walls_left[1];
    new_state.game_over = game_over;
    return new_state;
  }

  std::vector<Action> getLegalActions() const {
    std::vector<Action> actions;

    // 이동 가능한 위치 추가
    auto player_pos = board.getPlayerPosition(current_player);
    auto possible_moves =
        Pawn::getPossibleMoves(board, player_pos.first, player_pos.second);
    for (const auto &move : possible_moves) {
      actions.emplace_back(ActionType::MOVE, move.first, move.second);
    }

    // 벽을 놓을 수 있는 경우만 추가
    if (walls_left[current_player - 1] > 0) {
      auto horizontal_walls = Wall::getPossibleHorizontalWalls(board);
      auto vertical_walls = Wall::getPossibleVerticalWalls(board);

      for (const auto &wall : horizontal_walls) {
        if (Wall::validateWallPlacement(board, wall.first, wall.second, true)) {
          actions.emplace_back(ActionType::HORIZONTAL_WALL, wall.first,
                               wall.second);
        }
      }

      for (const auto &wall : vertical_walls) {
        if (Wall::validateWallPlacement(board, wall.first, wall.second,
                                        false)) {
          actions.emplace_back(ActionType::VERTICAL_WALL, wall.first,
                               wall.second);
        }
      }
    }

    return actions;
  }

  bool makeAction(const Action &action) {
    if (game_over)
      return false;

    bool action_success = false;

    switch (action.type) {
    case ActionType::MOVE:
      action_success = board.placePawn(action.row, action.col, current_player);
      break;

    case ActionType::HORIZONTAL_WALL:
      if (walls_left[current_player - 1] > 0 &&
          Wall::validateWallPlacement(board, action.row, action.col, true)) {
        action_success = board.placeHorizontalWall(action.row, action.col);
        if (action_success)
          walls_left[current_player - 1]--;
      }
      break;

    case ActionType::VERTICAL_WALL:
      if (walls_left[current_player - 1] > 0 &&
          Wall::validateWallPlacement(board, action.row, action.col, false)) {
        action_success = board.placeVerticalWall(action.row, action.col);
        if (action_success)
          walls_left[current_player - 1]--;
      }
      break;
    }

    if (action_success) {
      if (board.isWinningPosition(current_player)) {
        game_over = true;
      } else {
        current_player = (current_player == 1) ? 2 : 1;
      }
    }

    return action_success;
  }

  // Getter 메서드들
  bool isGameOver() const { return game_over; }
  int getCurrentPlayer() const { return current_player; }
  int getWallsLeft(int player) const { return walls_left[player - 1]; }
  const Board &getBoard() const { return board; }

  void printState() const {
    std::cout << "Current Player: P" << current_player << "\n";
    std::cout << "Walls Left - P1: " << walls_left[0]
              << ", P2: " << walls_left[1] << "\n";
    std::cout << "Game Over: " << (game_over ? "Yes" : "No") << "\n\n";
    board.printBoard();
  }
};

#endif // QUORIDOUBLE_CORE_STATE_HPP_