// include/quoridouble/action.hpp
#ifndef QUORIDOUBLE_CORE_ACTION_HPP_
#define QUORIDOUBLE_CORE_ACTION_HPP_

enum class ActionType { MOVE, HORIZONTAL_WALL, VERTICAL_WALL };

struct Action {
  ActionType type;
  int row;
  int col;

  Action(ActionType t, int r, int c) : type(t), row(r), col(c) {}
};

#endif // QUORIDOUBLE_CORE_ACTION_HPP_