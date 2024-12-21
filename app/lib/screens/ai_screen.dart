import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:quoridouble/widgets/board_widgets/index.dart';
import 'package:quoridouble/widgets/board_widgets/function.dart';
import 'package:quoridouble/screens/home_screen.dart';
import 'package:quoridouble/utils/AI/index.dart';
import 'package:quoridouble/utils/game_state.dart';
import 'package:quoridouble/widgets/ai_widgets/game_menu_dialog.dart';
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
  List<String> wallCoord = [];
  String wallTempCoord = "";

  Timer? _timer; // 타이머 변수
  int ms = 0; // 초 단위 시간
  bool _isRunning = false; // 타이머 상태
  bool _hasRunOnce = false;

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
        wallCoord.add(col + row);
      } else {
        x += 2;
        x = 16 - x;
        y = 16 - y;

        String row = String.fromCharCode(64 + y ~/ 2 + y % 2);
        String col = (x ~/ 2 + 1).toString();
        wallCoord.add(row + col);
      }
    }
  }

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

  void _toggleTimer() {
    setState(() {
      if (_isRunning) {
        // 타이머 멈춤
        _timer?.cancel();
        _timer = null;
      } else {
        // 타이머 시작
        ms = 0;
        _timer = Timer.periodic(const Duration(milliseconds: 1), (timer) {
          setState(() {
            ms++;
          });
        });
      }
      _isRunning = !_isRunning;
    });
  }

  @override
  void dispose() {
    // 타이머 정리
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    ms = 0;
    super.dispose();
  }

  String _formatTime(int milliseconds) {
    // 밀리초를 초로 변환
    int seconds = (milliseconds / 1000).floor();

    // 밀리초를 2자리로 포맷
    int remainingMilliseconds =
        (milliseconds % 1000) ~/ 10; // 밀리초를 10ms 단위로 반올림

    // 초:밀리초 형식으로 반환
    return '${seconds.toString().padLeft(2, '0')}:${remainingMilliseconds.toString().padLeft(2, '0')}';
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

    /// ****************************************************************************************
    /// AI의 turn
    /// ****************************************************************************************

    // compute에서 실행될 함수
    int actionLevelWorker(Map<String, dynamic> args) {
      GameState gameState = args['gameState'];
      int level = args['level'];
      return actionLevel(gameState, level);
    }

    // AI 행동 처리 메서드
    void handleAITurn() async {
      // AI의 턴인지 확인
      if (!isAITurn()) return;

      try {
        if (mounted) {
          setState(() {
            _toggleTimer();
          });
        }
        final Stopwatch stopwatch = Stopwatch()..start();

        // compute를 통해 AI의 액션 계산
        int action = await compute(
            actionLevelWorker, {'gameState': gameState, 'level': level});

        stopwatch.stop();
        int execution = stopwatch.elapsedMilliseconds;

        // 최소 지연 시간 보장
        await Future.delayed(Duration(milliseconds: max(0, 500 - execution)));

        // mounted 확인 후 상태 업데이트
        if (mounted) {
          setState(() {
            updateGameState(action);
            // 타이머 중지
            _toggleTimer();
          });
        }
      } catch (e) {
        print('AI 턴 처리 중 오류 발생: $e');
        // 오류 발생 시 타이머 중지
        if (mounted) {
          setState(() {
            _toggleTimer();
          });
        }
      }
    }

    if (!_hasRunOnce) {
      _hasRunOnce = true; // 실행 플래그 설정
      if (isAITurn()) {
        handleAITurn();
      }
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
                        child: GameMenuDialog(
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
                                        HomeScreen(),
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
              child: QuoridorBoard(
                boardSize: boardSize,
                gameState: gameState,
                isFirst: isFirst,
                user1: user1,
                user2: user2,
                wall: wallCoord,
                wallTempCoord: wallTempCoord,
                startPoint: startPoint,
                endPoint: endPoint,
                emptyTempWall: () => setState(() {
                  wallTempCoord = "";
                }),
                setPoint: (start, end) {
                  setState(() {
                    startPoint = start;
                    endPoint = end;
                  });
                },
                onPanUpdate: (distance, details) => setState(() {
                  if (distance > 5) {
                    endPoint = details;
                  }
                }),
                resetPoint: () => setState(() {
                  startPoint = null;
                  endPoint = null;
                }),
                onSetPlayer: (startPoint) => setState(() {
                  Map<String, dynamic> result = setPlayer(
                      startPoint, cellSize, spacing, user1, isFirst, gameState);

                  gameState = result['gameState'];
                  user1 = result['user1'];
                  user2 = result['user2'];
                  handleAITurn();
                }),
                onSetWallTemp: (startPoint, endPoint) => setState(() {
                  wallTempCoord = setWallTemp(
                      startPoint, endPoint, cellSize, spacing, gameState);
                }),
                onSetWall: () => setState(() {
                  Map<String, dynamic> result =
                      setWall(wallTempCoord, wallCoord, gameState);

                  gameState = result['gameState'];
                  wallTempCoord = result['wallTemp']; // 빈 문자열
                  handleAITurn();
                }),
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
                  'Delay ${_formatTime(ms)}s',
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
                                      HomeScreen(),
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
