import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:quoridouble/widgets/board_widgets/wall_placement_painter.dart';
import 'package:quoridouble/widgets/board_widgets/walls_widget.dart';
import 'package:quoridouble/widgets/board_widgets/board_grid_widget.dart';
import 'package:quoridouble/widgets/board_widgets/move_button_widget.dart';
import 'package:quoridouble/widgets/board_widgets/pieces_widget.dart';
import 'package:quoridouble/widgets/board_widgets/wall_temp_widget.dart';
import 'package:quoridouble/widgets/board_widgets/function.dart';
import 'package:quoridouble/widgets/board_widgets/board_interaction_widget.dart';
import 'package:quoridouble/screens/home_screen.dart';
import 'package:quoridouble/utils/AI/index.dart';
import 'package:quoridouble/utils/game_state.dart';
import 'package:quoridouble/widgets/ai_widgets/game_pause_dialog.dart';
import 'package:quoridouble/widgets/ai_widgets/game_result_dialog.dart';

class AIScreen extends StatefulWidget {
  final int level;
  final int isOrder;

  const AIScreen({super.key, required this.level, required this.isOrder});

  @override
  AIScreenState createState() => AIScreenState();
}

class AIScreenState extends State<AIScreen> {
  // board 관련 변수
  Offset? startPoint;
  Offset? endPoint;
  List<String> wall = [];
  String wallTempCoord = "";

  int executionTime = 0;

  final String title = 'AI Game';
  late int level;
  late int isOrder;

  /// ****************************************************************************************
  /// game 핵심 속성과 페이지 초기화
  /// ****************************************************************************************

  late GameState gameState;
  late List<int> user1;
  late List<int> user2;
  late int isFirst;

  @override
  void initState() {
    super.initState();
    startPoint = null;
    endPoint = null;

    level = widget.level;
    isOrder = widget.isOrder;

    isFirst = isOrder == 0
        ? (Random().nextBool() ? 0 : 1)
        : isOrder == 1
            ? 0
            : 1;

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

    // Board 관련 사이즈 정의
    double boardSize = screenWidth > 480 ? screenWidth * 0.8 : screenWidth - 10;
    double boardBoarder = boardSize * 0.01;
    final double spacing = boardSize * 0.02;
    final double cellSize = (boardSize - 2 * boardBoarder - 10 * spacing) / 9;

    WallPlacementPainter painter =
        WallPlacementPainter(startPoint, endPoint, cellSize, spacing);

    /// ****************************************************************************************
    /// AI의 turn
    /// ****************************************************************************************

    // compute에서 실행될 함수
    int actionLevelWorker(Map<String, dynamic> args) {
      GameState gameState = args['gameState'];
      int level = args['level'];
      return actionLevel(gameState, level);
    }

    // AI의 턴인지 확인하는 메서드
    bool isAITurn() {
      return !gameState.isLose() && gameState.isCurrentTurn(1 - isFirst);
    }

    void updateGameState(int action) {
      gameState = gameState.next(action);
      user1 = gameState.user1Pos(isFirst);
      user2 = gameState.user2Pos(isFirst);

      // 벽 배치 로직
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
    }

    // AI 행동 처리 메서드
    void handleAITurn() async {
      // AI의 턴인지 다시 한 번 확인
      if (!isAITurn()) return;

      try {
        final Stopwatch stopwatch = Stopwatch()..start();

        // compute를 통해 AI의 액션 계산
        int action = await compute(
            actionLevelWorker, {'gameState': gameState, 'level': level});

        stopwatch.stop();
        int execution = stopwatch.elapsedMilliseconds;

        // 최소 지연 시간 보장
        await Future.delayed(Duration(milliseconds: max(0, 500 - execution)));

        // 상태 업데이트
        setState(() {
          executionTime = execution;
          updateGameState(action);
        });
      } catch (e) {
        print('AI 턴 처리 중 오류 발생: $e');
      }
    }

    // 위젯 빌드 후 AI 턴 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isAITurn()) {
        handleAITurn();
      }
    });

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
                                        AIScreen(
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
                width: boardSize, // 정사각형의 가로 크기
                height: boardSize, // 정사각형의 세로 크기
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color.fromARGB(255, 107, 49, 54), // 테두리 색상
                    width: boardBoarder, // 테두리 두께
                  ),
                  borderRadius: BorderRadius.circular(10.0), // 모서리 둥글기
                ),
                padding: EdgeInsets.all(spacing), // 내부 여백
                child: Stack(
                  children: [
                    BoardGridWidget(spacing: spacing),
                    CustomPaint(painter: painter),
                    WallsWidget(
                        wall: wall, cellSize: cellSize, spacing: spacing),
                    PiecesWidget(
                      user1: user1,
                      user2: user2,
                      cellSize: cellSize,
                      spacing: spacing,
                      isFirst: isFirst,
                    ),

                    // 플레이어 이동 가능 방향을 보여줌
                    if (!gameState.isLose() &&
                        gameState.isCurrentTurn(isFirst) &&
                        wallTempCoord.isEmpty)
                      MoveButtonWidget(
                        gameState: gameState,
                        user1: user1,
                        cellSize: cellSize,
                        spacing: spacing,
                      ),

                    // 조건에 따라 GestureDetector 설정
                    if (!gameState.isLose() && gameState.isCurrentTurn(isFirst))
                      BoardInteractionWidget(
                        tempWall: wallTempCoord,
                        boardSize: boardSize,
                        boardBoarder: boardBoarder,
                        spacing: spacing,
                        startPoint: startPoint,
                        endPoint: endPoint,
                        emptyTempWall: () => setState(() {
                          wallTempCoord = "";
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
                          wallTempCoord = setWallTemp(startPoint, endPoint, cellSize,
                              spacing, gameState);
                        }),
                        resetPoint: () => setState(() {
                          startPoint = null;
                          endPoint = null;
                        }),
                      ),

                    WallTempWidget(
                      wallTemp: wallTempCoord,
                      cellSize: cellSize,
                      spacing: spacing,
                      touchMargin: cellSize / 2,
                      onTap: () => setState(() {
                        Map<String, dynamic> result =
                            setWall(wallTempCoord, wall, gameState);
                        gameState = result['gameState'];
                        wallTempCoord = result['wallTemp']; // 빈 문자열
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // 좌측 상단
            Positioned(
              top: (screenHeight - kToolbarHeight - statusBarHeight) / 2 -
                  25 -
                  boardSize / 2 -
                  20, // 중앙에서 위로 배치
              left: (screenWidth - boardSize) / 2 + 5,
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

            // 우측 상단
            Positioned(
              top: (screenHeight - kToolbarHeight - statusBarHeight) / 2 -
                  25 -
                  boardSize / 2 -
                  20, // 중앙에서 위로 배치
              right: (screenWidth - boardSize) / 2 + 5,
              child: Container(
                height: 50, // 위젯 높이
                alignment: Alignment.center,
                child: Text(
                  "Delay ${(executionTime / 1000).toStringAsFixed(2)} s",
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
                  boardSize / 2 +
                  20, // 중앙에서 아래로 배치
              left: (screenWidth - boardSize) / 2 + 5,
              child: Container(
                height: 50, // 위젯 높이
                alignment: Alignment.center,
                child: Text(
                  'Timer \u221E',
                  style: TextStyle(
                    fontSize: 18,
                    color: gameState.isCurrentTurn(isFirst)
                        ? const Color.fromARGB(255, 255, 0, 0) // 불투명
                        : const Color.fromARGB(128, 255, 0, 0), // 50% 투명
                  ),
                ),
              ),
            ),
            //  우측 하단
            Positioned(
              top: (screenHeight - kToolbarHeight - statusBarHeight) / 2 -
                  25 +
                  boardSize / 2 +
                  20, // 중앙에서 아래로 배치
              right: (screenWidth - boardSize) / 2 + 5,
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
                                      AIScreen(
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
