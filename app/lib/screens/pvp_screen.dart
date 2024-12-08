import 'package:flutter/material.dart';
import 'package:quoridouble/widgets/gameboard/components2/legal_moves.dart';
import 'package:quoridouble/widgets/gameboard/components2/player_pins.dart';
import 'package:quoridouble/widgets/gameboard/components2/walls.dart';
import 'package:quoridouble/utils/game.dart';
import 'package:quoridouble/utils/socket_service.dart';
import 'package:quoridouble/widgets/gameboard/components1/board_interaction.dart';
import 'package:quoridouble/widgets/gameboard/components1/game_grid.dart';
import 'package:quoridouble/widgets/gameboard/components1/wall_temp.dart';
import 'package:quoridouble/widgets/pvp_screen/game_pause_dialog.dart';
import 'package:quoridouble/widgets/gameboard/components1/line_painter.dart';
import 'package:quoridouble/widgets/pvp_screen/game_result_dialog.dart';
import 'home_screen.dart';

class RoomScreen extends StatefulWidget {
  final int isFirst;
  final SocketService socketService;

  const RoomScreen({
    super.key,
    required this.isFirst,
    required this.socketService,
  });

  @override
  RoomScreenState createState() => RoomScreenState();
}

class RoomScreenState extends State<RoomScreen> {
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
  String wallTemp = "";

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
      Map<String, dynamic> parsedData = Map<String, dynamic>.from(data);

      // action 값 가져오기
      int action = parsedData['action'];
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

    final double cellSize = (screenWidth - 100) / 9;
    const double spacing = 8;

    LinePainter painter = LinePainter(startPoint, endPoint, cellSize);

    /// ****************************************************************************************
    /// 보드판과 gameState 간의 상호작용 함수
    /// ****************************************************************************************

    List<int> eventToIndex(Offset event) {
      double boundary = cellSize + spacing;
      int x = 2 * (event.dx ~/ boundary); // 가로
      int y = 2 * (event.dy ~/ boundary); // 세로

      if (boundary * ((event.dx ~/ boundary) + 1) - event.dx < spacing) {
        x += 1; // 가로
      }

      if (boundary * ((event.dy ~/ boundary) + 1) - event.dy < spacing) {
        y += 1; // 세로
      }

      return [x, y];
    }

    void setPlayer(Offset event) {
      // 클릭 위치를 행동으로 변환
      List<int> pos = eventToIndex(event);

      List legalMove = gameState.legalMoves();

      List<int> target = [pos[1] - (user1[0] * 2), pos[0] - (user1[1] * 2)];

      bool exists = legalMove
          .any((element) => element[0] == target[0] && element[1] == target[1]);

      setState(() {
        if (exists) {
          List<List<int>> moves = [
            [-2, 0], // N (인덱스 0)
            [-2, 2], // NE (인덱스 1)
            [0, 2], // E (인덱스 2)
            [2, 2], // SE (인덱스 3)
            [2, 0], // S (인덱스 4)
            [2, -2], // SW (인덱스 5)
            [0, -2], // W (인덱스 6)
            [-2, -2], // NW (인덱스 7)
            [-4, 0], // NN (인덱스 8)
            [0, 4], // EE (인덱스 9)
            [4, 0], // SS (인덱스 10)
            [0, -4], // WW (인덱스 11)
          ];

          int? findIndex(List<List<int>> moves, List<int> target) {
            for (int i = 0; i < moves.length; i++) {
              if (moves[i][0] == target[0] && moves[i][1] == target[1]) {
                return i;
              }
            }
            return null; // 찾지 못한 경우
          }

          int? action = findIndex(moves, target);

          gameState = gameState.next(action!);
          user1 = gameState.user1Pos(isFirst);
          user2 = gameState.user2Pos((isFirst));

          socketService.socket?.emit('gameData', {'action': action});
        }
      });
    }

    int locationToWallIndex(double location) {
      double padding = cellSize / 2;
      int index = 0;

      for (int i = 1; i <= 8; i++) {
        if (i * cellSize + (i - 1) * spacing - padding <= location &&
            location <= i * (cellSize + spacing) + padding) {
          index = i;
        }
      }

      return index;
    }

    int locationToWallOtherIndex(double location) {
      int index = 0;

      for (int i = 1; i <= 9; i++) {
        if ((i - 1) * (cellSize + spacing) <= location &&
            location <= (i - 1) * (cellSize + spacing) + cellSize) {
          index = i;
        }
      }

      return index;
    }

    void setWallTemp(Offset start, Offset end) {
      // 두 점 사이의 거리 계산
      double distance = (start - end).distance;

      // 길이가 일정이상 이여야 동작함.
      if (distance >= cellSize + spacing) {
        // 세로 직선
        if (start.dx == end.dx) {
          int wallIndex = locationToWallIndex(start.dx);

          // X가 범위내에 들어와 있는지 확인
          if (wallIndex != 0) {
            String col = String.fromCharCode(64 + wallIndex);
            // print("vertical index : $col");

            if (start.dy > end.dy) {
              // print('세로: 아래에서 위로');
              int wallOtherIndex = locationToWallOtherIndex(start.dy - spacing);
              String row = (wallOtherIndex - 1).toString();

              if (wallOtherIndex != 0) {
                int action = gameState.xyToWallAction(
                    2 * (wallOtherIndex - 2), 2 * wallIndex - 1);

                if (gameState.legalActions().contains(action)) {
                  wallTemp = col + row;
                }
              }
            } else if (start.dy < end.dy) {
              // print('세로: 위에서 아래로');
              int wallOtherIndex = locationToWallOtherIndex(start.dy + spacing);
              String row = wallOtherIndex.toString();

              if (wallOtherIndex != 0) {
                int action = gameState.xyToWallAction(
                    2 * (wallOtherIndex - 1), 2 * wallIndex - 1);

                if (gameState.legalActions().contains(action)) {
                  wallTemp = col + row;
                }
              }
            }
          }
        }

        // 가로 직선
        if (start.dy == end.dy) {
          int wallIndex = locationToWallIndex(start.dy);

          // Y가 범위내에 들어와 있는지 확인
          if (wallIndex != 0) {
            String row = wallIndex.toString();
            // print("horizontal index : $wallIndex");

            if (start.dx > end.dx) {
              // print('가로: 오른쪽에서 왼쪽으로');
              int wallOtherIndex = locationToWallOtherIndex(start.dx - spacing);
              String col = String.fromCharCode(64 + wallOtherIndex - 1);

              if (wallOtherIndex != 0) {
                int action = gameState.xyToWallAction(
                    2 * wallIndex - 1, 2 * (wallOtherIndex - 2));

                if (gameState.legalActions().contains(action)) {
                  wallTemp = row + col;
                }
              }
            } else if (start.dx < end.dx) {
              // print('가로: 왼쪽에서 오른쪽으로');
              int wallOtherIndex = locationToWallOtherIndex(start.dx + spacing);
              String col = String.fromCharCode(64 + wallOtherIndex);

              if (wallOtherIndex != 0) {
                int action = gameState.xyToWallAction(
                    2 * wallIndex - 1, 2 * (wallOtherIndex - 1));

                if (gameState.legalActions().contains(action)) {
                  wallTemp = row + col;
                }
              }
            }
          }
        }
      }
    }

    void setWall() {
      if (wallTemp.isNotEmpty) {
        // 처음 문자열이 단일 숫자(True)인지 문자(False)인지 확인함
        // true는 가로 false는 세로를 의미함
        bool isNumber = wallTemp[0].contains(RegExp(r'[0-9]'));

        int x = isNumber
            ? 2 * int.parse(wallTemp[0]) - 1
            : 2 * (int.parse(wallTemp[1]) - 1);

        int y = isNumber
            ? 2 * (wallTemp[1].codeUnitAt(0) - 'A'.codeUnitAt(0))
            : 2 * (wallTemp[0].codeUnitAt(0) - 'A'.codeUnitAt(0)) + 1;

        int action = gameState.xyToWallAction(x, y);

        setState(() {
          gameState = gameState.next(action);
          socketService.socket?.emit('gameData', {'action': action});
          wall.add(wallTemp);
          wallTemp = ""; // wallTemp를 빈 문자열로 지우기
        });
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
                          setPlayer(startPoint);
                        }),
                        setWallTemp: (startPoint, endPoint) => setState(() {
                          setWallTemp(startPoint, endPoint); // 벽 임시 설정
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
                      onTap: setWall,
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
                child: Text('Walls ${gameState.getUser2WallCount((isFirst))}',
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color.fromARGB(255, 255, 0, 0),
                    )),
              ),
            ),
            //  좌측 상단
            Positioned(
              top: (screenHeight - kToolbarHeight - statusBarHeight) / 2 -
                  25 +
                  (screenWidth - 10) / 2 +
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
