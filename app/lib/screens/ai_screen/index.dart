import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:quoridouble/widgets/gameboard/utils.dart';
import 'package:quoridouble/widgets/gameboard/components1/game_grid.dart';
import 'package:quoridouble/widgets/gameboard/components2/legal_moves.dart';
import 'package:quoridouble/widgets/gameboard/components2/player_pins.dart';
import 'package:quoridouble/widgets/gameboard/components2/walls.dart';
import 'package:quoridouble/widgets/gameboard/components1/board_interaction.dart';
import 'package:quoridouble/widgets/gameboard/components1/wall_temp.dart';
import 'package:quoridouble/screens/home_screen.dart';
import 'package:quoridouble/utils/AI/index.dart';
import 'package:quoridouble/utils/game.dart';
import 'package:quoridouble/widgets/gameboard/components1/line_painter.dart';
import 'package:quoridouble/widgets/ai_screen/game_pause_dialog.dart';
import 'package:quoridouble/widgets/ai_screen/game_result_dialog.dart';

class QuoridoubleAIScreen extends StatefulWidget {
  final int level;
  final int isOrder;

  const QuoridoubleAIScreen(
      {super.key, required this.level, required this.isOrder});

  @override
  QuoridoubleAIScreenState createState() => QuoridoubleAIScreenState();
}

class QuoridoubleAIScreenState extends State<QuoridoubleAIScreen> {
  Offset? startPoint;
  Offset? endPoint;

  final String title = 'AI Game';
  late int level;
  late int isOrder;
  late int isFirst;

  /// ****************************************************************************************
  /// game 핵심 속성과 페이지 초기화
  /// ****************************************************************************************

  late GameState gameState;
  late List<int> user1;
  late List<int> user2;

  List<String> wall = [];
  String wallTemp = "";

  @override
  void initState() {
    super.initState();
    level = widget.level;
    isOrder = widget.isOrder;

    isFirst = isOrder == 0
        ? (Random().nextBool() ? 0 : 1)
        : isOrder == 1
            ? 0
            : 1;

    startPoint = null;
    endPoint = null;

    initializeGame();
  }

  void initializeGame() {
    gameState = GameState();

    user1 = gameState.user1Pos(isFirst);
    user2 = gameState.user2Pos(isFirst);
  }

  /// ********************************************

  @override
  Widget build(BuildContext context) {
    // 화면의 전체 너비를 가져오기
    double screenWidth = MediaQuery.of(context).size.width;
    // 화면의 전체 높이를 가져오기
    double screenHeight = MediaQuery.of(context).size.height;
    // 상태바 높이
    double statusBarHeight = MediaQuery.of(context).padding.top;

    final double cellSize = (screenWidth - 100) / 9;
    const double spacing = 8;

    LinePainter painter = LinePainter(startPoint, endPoint, cellSize);

    /// ****************************************************************************************
    /// AI의 turn
    /// ****************************************************************************************

    // compute에서 실행될 함수
    int actionLevelWorker(Map<String, dynamic> args) {
      GameState gameState = args['gameState'];
      int level = args['level'];
      return actionLevel(gameState, level);
    }

    // actionLevel 비동기 실행
    Future<int> computeActionLevel(GameState gameState, int level) async {
      return await compute(
          actionLevelWorker, {'gameState': gameState, 'level': level});
    }

    if (!gameState.isLose() && gameState.isCurrentTurn(1 - isFirst)) {
      Future.delayed(Duration(seconds: 1), () async {
        // actionLevel을 compute에서 실행
        int action = await computeActionLevel(gameState, level);

        if (mounted) {
          setState(() {
            gameState = gameState.next(action);
            user1 = gameState.user1Pos(isFirst);
            user2 = gameState.user2Pos(isFirst);

            if (action >= 12 && action <= 139) {
              bool isHorizontalWall = action > 75;
              action -= isHorizontalWall ? 75 : 11;

              int quotient = action ~/ 8;
              int remainder = action % 8;

              int x = (remainder != 0) ? 2 * remainder - 2 : 14;
              int y = 2 * quotient + (remainder != 0 ? 1 : -1);

              if (isHorizontalWall) {
                int temp = x;
                x = y;
                y = temp;

                y += 2;
                x = 16 - x;
                y = 16 - y;

                String col = (x ~/ 2 + x % 2).toString();
                String row = String.fromCharCode(65 + y ~/ 2);
                wall.add(col + row);
              } else {
                x += 2;
                x = 16 - x;
                y = 16 - y;

                String row = String.fromCharCode(64 + y ~/ 2 + y % 2);
                String col = (x ~/ 2 + 1).toString();
                wall.add(row + col);
              }
            }
          });
        }
      });
    }

    /// ****************************************************************************************
    /// background and appbar
    /// ****************************************************************************************

    return Stack(children: <Widget>[
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background-yellow.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
      Scaffold(
          // 배경색을 투명으로 설정
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.transparent,
            centerTitle: false, // 타이틀을 좌측에 정렬
            actions: [
              IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.8,
                        child: GamePauseDialog(
                          onRematch: () {
                            // 재시작 로직
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        QuoridoubleAIScreen(
                                  level: widget.level,
                                  isOrder: widget.isOrder,
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          onExit: () {
                            // 종료 로직
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        HomeScreen(page: 0),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          /// ****************************************************************************************
          /// board widget
          /// ****************************************************************************************

          body: Stack(children: [
            Center(
              child: Container(
                width: screenWidth - 10, // 정사각형의 가로 크기
                height: screenWidth - 10, // 정사각형의 세로 크기
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color.fromARGB(255, 107, 49, 54), // 테두리 색상
                    width: 5.0, // 테두리 두께
                  ),
                  borderRadius: BorderRadius.circular(10.0), // 모서리 둥글기
                ),
                padding: EdgeInsets.all(spacing), // 내부 여백
                child: Stack(
                  children: [
                    GameGrid(spacing: spacing),
                    CustomPaint(painter: painter),
                    Walls(wall: wall, cellSize: cellSize, spacing: spacing),
                    PlayerPins(
                      user1: user1,
                      user2: user2,
                      cellSize: cellSize,
                      spacing: spacing,
                      isFirst: isFirst,
                    ),

                    // 플레이어 이동 가능 방향을 보여줌
                    if (!gameState.isLose() &&
                        gameState.isCurrentTurn(isFirst) &&
                        wallTemp.isEmpty)
                      LegalMoves(
                        gameState: gameState,
                        user1: user1,
                        cellSize: cellSize,
                        spacing: spacing,
                      ),

                    // 조건에 따라 GestureDetector 설정
                    if (!gameState.isLose() && gameState.isCurrentTurn(isFirst))
                      BoardInteraction(
                        tempWall: wallTemp,
                        screenWidth: screenWidth,
                        startPoint: startPoint,
                        endPoint: endPoint,
                        emptyTempWall: () => setState(() {
                          wallTemp = "";
                        }),
                        setPoint: (start, end) {
                          print("setPoint called: start=$start, end=$end");
                          setState(() {
                            startPoint = start;
                            endPoint = end;
                          });
                        },
                        userWallCount: gameState.getUser1WallCount(isFirst),
                        onPanUpdate: (distance, details) => setState(() {
                          if (distance > 5) {
                            endPoint = details;
                          }
                        }),
                        setPlayer: (startPoint) => setState(() {
                          Map<String, dynamic> result = setPlayer(startPoint,
                              cellSize, spacing, user1, isFirst, gameState);
                          gameState = result['gameState'];
                          user1 = result['user1'];
                          user2 = result['user2'];
                        }),
                        setWallTemp: (startPoint, endPoint) => setState(() {
                          wallTemp = setWallTemp(startPoint, endPoint, cellSize,
                              spacing, gameState);
                        }),
                        resetPoint: () => setState(() {
                          startPoint = null;
                          endPoint = null;
                        }),
                      ),

                    WallTemp(
                      wallTemp: wallTemp,
                      cellSize: cellSize,
                      spacing: spacing,
                      touchMargin: cellSize / 2,
                      onTap: () {
                        Map<String, dynamic> result =
                            setWall(wallTemp, wall, gameState);
                        gameState = result['gameState'];
                        wallTemp = result['wallTemp']; // 빈 문자열
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 좌측 상단
            Positioned(
              top: (screenHeight - kToolbarHeight - statusBarHeight) / 2 -
                  25 -
                  (screenWidth - 10) / 2 -
                  20, // 중앙에서 위로 배치
              left: 10,
              child: Container(
                height: 50, // 위젯 높이
                alignment: Alignment.center,
                child: Text(
                  'Walls ${gameState.getUser2WallCount((isFirst))}',
                  style: TextStyle(
                    fontSize: 18,
                    color: gameState.isCurrentTurn(1 - isFirst)
                        ? const Color.fromARGB(255, 255, 0, 0) // 불투명
                        : const Color.fromARGB(128, 255, 0, 0), // 50% 투명
                  ),
                ),
              ),
            ),

            //  좌측 하단
            Positioned(
              top: (screenHeight - kToolbarHeight - statusBarHeight) / 2 -
                  25 +
                  (screenWidth - 10) / 2 +
                  20, // 중앙에서 아래로 배치
              right: 10,
              child: Container(
                height: 50, // 위젯 높이
                alignment: Alignment.center,
                child: Text(
                  'Walls ${gameState.getUser1WallCount((isFirst))}',
                  style: TextStyle(
                    fontSize: 18,
                    color: gameState.isCurrentTurn(isFirst)
                        ? const Color.fromARGB(255, 255, 0, 0) // 불투명
                        : const Color.fromARGB(128, 255, 0, 0), // 50% 투명
                  ),
                ),
              ),
            ),

            /// ****************************************************************************************
            /// pause dialog
            /// ****************************************************************************************

            if (gameState.isLose())
              Builder(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.8, // 화면 너비의 80%를 차지하도록 설정
                          child: GameResultDialog(
                            isWin:
                                gameState.isCurrentTurn(isFirst) ? false : true,
                            onRematch: () {
                              // 재시작 로직
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      QuoridoubleAIScreen(
                                    level: widget.level,
                                    isOrder: widget.isOrder,
                                  ),
                                  transitionDuration:
                                      Duration.zero, // 전환 애니메이션 시간 설정
                                  reverseTransitionDuration:
                                      Duration.zero, // 뒤로가기 애니메이션 시간 설정
                                ),
                              );
                            },
                            onExit: () {
                              // 종료 로직
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      HomeScreen(page: 0),
                                  transitionDuration:
                                      Duration.zero, // 전환 애니메이션 시간 설정
                                  reverseTransitionDuration:
                                      Duration.zero, // 뒤로가기 애니메이션 시간 설정
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  });
                  return Container(); // Builder 내부에서 아무것도 렌더링하지 않음
                },
              ),
          ])),
    ]);
  }
}
