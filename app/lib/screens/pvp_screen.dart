import 'package:flutter/material.dart';
import 'package:quoridouble/utils/game_state.dart';
import 'package:quoridouble/utils/socket_service.dart';
import 'package:quoridouble/widgets/board_widgets/board_interaction_widget.dart';
import 'package:quoridouble/widgets/board_widgets/wall_placement_painter.dart';
import 'package:quoridouble/widgets/board_widgets/walls_widget.dart';
import 'package:quoridouble/widgets/board_widgets/board_grid_widget.dart';
import 'package:quoridouble/widgets/board_widgets/move_button_widget.dart';
import 'package:quoridouble/widgets/board_widgets/pieces_widget.dart';
import 'package:quoridouble/widgets/board_widgets/wall_temp_widget.dart';
import 'package:quoridouble/widgets/board_widgets/function.dart';
import 'package:quoridouble/widgets/pvp_widgets/game_pause_dialog.dart';
import 'package:quoridouble/widgets/pvp_widgets/game_result_dialog.dart';
import 'home_screen.dart';

class PvPScreen extends StatefulWidget {
  final int isFirst;
  final SocketService socketService;

  const PvPScreen({
    super.key,
    required this.isFirst,
    required this.socketService,
  });

  @override
  PvPScreenState createState() => PvPScreenState();
}

class PvPScreenState extends State<PvPScreen> {
  Offset? startPoint;
  Offset? endPoint;

  final String title = 'PVP Game';

  late int isFirst = widget.isFirst;
  late SocketService socketService = widget.socketService;

  /// ********************************************
  /// game 핵심 속성
  /// ********************************************

  late GameState gameState;

  late List<int> user1;
  late List<int> user2;

  List<String> wall = [];
  String wallTempCoord = "";

  void initializeGame() {
    gameState = GameState();

    user1 = gameState.user1Pos(isFirst);
    user2 = gameState.user2Pos(isFirst);
  }

  @override
  void initState() {
    super.initState();
    initSocket();
    initializeGame();
  }

  /// ********************************************

  void initSocket() {
    socketService.socket?.on('opponentDisconnected', (data) {
      setState(() {
        // 받은 메시지 출력 (디버깅 용)
        print(data['message']);

        bool opponentDisconnected = false;

        // 메시지가 왔을 경우
        if (data['message'] != null) {
          setState(() {
            opponentDisconnected = true; // 상대방이 연결을 끊었음을 표시
          });
        }

        // 모달이 열려 있을 경우 닫기
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // 모달 닫기
        }

        // 페이지 이동
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
              page: 1,
              opponentDisconnected: opponentDisconnected,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      });
    });

    socketService.socket?.on('gameData', (data) {
      // action 값 가져오기
      int action = data['action'];
      print('Received action: $action');

      if (!gameState.isLose() && gameState.isCurrentTurn(1 - isFirst)) {
        setState(() {
          gameState = gameState.next(action);
          user1 = gameState.user1Pos(isFirst);
          user2 = gameState.user2Pos((isFirst));

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

  @override
  Widget build(BuildContext context) {
    // 화면의 전체 너비를 가져오기
    double screenWidth = MediaQuery.of(context).size.width;
    // 화면의 전체 높이를 가져오기
    double screenHeight = MediaQuery.of(context).size.height;
    // 상태바 높이
    double statusBarHeight = MediaQuery.of(context).padding.top;

    double boardSize = screenWidth - 10;
    double boardBoarder = boardSize * 0.01;
    final double spacing = boardSize * 0.02;
    final double cellSize = (boardSize - 2 * boardBoarder - 10 * spacing) / 9;

    WallPlacementPainter painter =
        WallPlacementPainter(startPoint, endPoint, cellSize, spacing);

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
                icon: Icon(Icons.menu_rounded),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.8,
                        child: GamePauseDialog(
                          onExit: () {
                            // 종료 로직
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        HomeScreen(page: 1),
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
              )
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

                          if (result['action'] != null) {
                            Map<String, int> gameData = {
                              'action': result['action'],
                            };
                            socketService.socket?.emit('gameData', gameData);
                          }
                        }),
                        setWallTemp: (startPoint, endPoint) => setState(() {
                          wallTempCoord = setWallTemp(startPoint, endPoint,
                              cellSize, spacing, gameState);
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

                        if (result['action'] != null) {
                          Map<String, int> gameData = {
                            'action': result['action'],
                          };
                          socketService.socket?.emit('gameData', gameData);
                        }
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
              left: 10,
              child: Container(
                height: 50, // 위젯 높이
                alignment: Alignment.center,
                child: Text('Walls ${gameState.getUser2WallCount((isFirst))}',
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color.fromARGB(255, 255, 0, 0),
                    )),
              ),
            ),
            //  우측 하단
            Positioned(
              top: (screenHeight - kToolbarHeight - statusBarHeight) / 2 -
                  25 +
                  boardSize / 2 +
                  20, // 중앙에서 아래로 배치
              right: 10,
              child: Container(
                height: 50, // 위젯 높이
                alignment: Alignment.center,
                child: Text('Walls ${gameState.getUser1WallCount((isFirst))}',
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color.fromARGB(255, 255, 0, 0),
                    )),
              ),
            ),

            /// ****************************************************************************************
            /// dialog
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

  @override
  void dispose() {
    socketService.disconnect();
    super.dispose(); // 부모 클래스의 dispose 호출
  }
}
