import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quoridouble/utils/game.dart';
import 'package:quoridouble/widgets/line_painter.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'home_screen.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  RoomScreenState createState() => RoomScreenState();
}

class RoomScreenState extends State<RoomScreen> {
  Offset? startPoint;
  Offset? endPoint;

  final String title = 'PVP Game';
  final int _blockCounter = 9;

  late io.Socket socket;
  String? socketMessage;

  /// ********************************************
  /// game 핵심 속성
  /// ********************************************

  late GameState gameState;
  late int isFirst;
  late List<int> user1;
  late List<int> user2;

  List<String> wall = [];
  String wallTemp = "";

  void initializeGame() {
    gameState = GameState();

    isFirst = 1;

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
    socket = io.io('${dotenv.env['SERVER_URL']}/room', <String, dynamic>{
      'transports': ['websocket'],
      'path': '/socket.io',
      'autoConnect': true,
      'reconnection': false,
    });

    socket.onConnect((_) {
      print('소켓에 연결됨');
    });

    // 소켓 연결 해제 이벤트 처리
    socket.onDisconnect((_) {
      print('소켓이 연결 해제됨');
    });

    // 대기 중 메시지 수신
    socket.on('waiting', (message) {
      setState(() {
        socketMessage = message;
      });
    });

    socket.on('opponentDisconnected', (data) {
      setState(() {
        // 상대방이 연결을 끊었을 때 메시지를 표시
        socketMessage = data['message'];
      });
    });

    // 게임 시작 알림 수신
    socket.on('startGame', (data) {
      int isFirst = data['isFirst'];
      // isFirst :0 이면 선수, :1이면 후수
      print("게임 시작: 방 ID - ${data['roomId']}, isFirst - $isFirst");

      setState(() {
        this.isFirst = isFirst;
        socketMessage = null;
      });
    });

    socket.on('gameData', (data) {
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

    // 회전 각도를 계산하는 함수를 추가함.
    double getRotationAngle(List<int> target) {
      final int x = target[0];
      final int y = target[1];

      return (atan2(y, -x) + 2 * pi) % (2 * pi);
    }

    /// ********************************************
    /// game 핵심 기능
    /// ********************************************

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

          socket.emit('gameData', {'action': action});
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
          socket.emit('gameData', {'action': action});
          wall.add(wallTemp);
          wallTemp = ""; // wallTemp를 빈 문자열로 지우기
        });
      }
    }

    /// ********************************************

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
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          HomeScreen(page: 1),
                      transitionDuration: Duration.zero, // 전환 애니메이션 시간 설정
                      reverseTransitionDuration:
                          Duration.zero, // 뒤로가기 애니메이션 시간 설정
                    ),
                  );
                },
              )
            ],
          ),
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
                    GridView.count(
                      physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화
                      crossAxisCount: _blockCounter,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                      children:
                          List.generate(_blockCounter * _blockCounter, (index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 237, 237, 237),
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        );
                      }),
                    ),

                    CustomPaint(
                      painter: painter,
                    ),

                    for (String wallInfo in wall)
                      Builder(builder: (BuildContext context) {
                        // 처음 문자열이 단일 숫자(True)인지 문자(False)인지 확인함
                        bool isHorizontalWall =
                            wallInfo[0].contains(RegExp(r'[0-9]'));

                        int topCon = isHorizontalWall
                            ? int.parse(wallInfo[0])
                            : int.parse(wallInfo[1]);

                        int leftCon = isHorizontalWall
                            ? wallInfo[1].codeUnitAt(0) - 'A'.codeUnitAt(0)
                            : wallInfo[0].codeUnitAt(0) - 'A'.codeUnitAt(0);

                        final double top = isHorizontalWall
                            ? topCon * cellSize + spacing * (topCon - 1)
                            : (topCon - 1) * (cellSize + spacing);

                        final double left = isHorizontalWall
                            ? leftCon * (cellSize + spacing)
                            : (leftCon + 1) * cellSize + spacing * leftCon;

                        return Positioned(
                          top: top,
                          left: left,
                          child: Container(
                            width: isHorizontalWall
                                ? 2 * cellSize + spacing
                                : spacing,
                            height: isHorizontalWall
                                ? spacing
                                : 2 * cellSize + spacing,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 127, 80),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }),

                    AnimatedPositioned(
                        duration: Duration(milliseconds: 500), // 애니메이션 지속 시간
                        curve: Curves.easeInOut, // 애니메이션 곡선
                        top: user1[0] * (cellSize + spacing),
                        left: user1[1] * (cellSize + spacing),
                        width: cellSize,
                        height: cellSize,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            isFirst == 0
                                ? 'assets/images/white_pin.svg'
                                : 'assets/images/black_pin.svg',
                          ),
                        )),
                    AnimatedPositioned(
                        duration: Duration(milliseconds: 500), // 애니메이션 지속 시간
                        curve: Curves.easeInOut, // 애니메이션 곡선
                        top: user2[0] * (cellSize + spacing),
                        left: user2[1] * (cellSize + spacing),
                        width: cellSize,
                        height: cellSize,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            isFirst == 1
                                ? 'assets/images/white_pin.svg'
                                : 'assets/images/black_pin.svg',
                          ),
                        )),

                    // 플레이어 이동 가능 방향을 보여줌
                    if (!gameState.isLose() &&
                        gameState.isCurrentTurn(isFirst) &&
                        wallTemp.isEmpty)
                      for (List<int> target in gameState.legalMoves())
                        Positioned(
                            top: (target[0] ~/ 2 + user1[0]) *
                                (cellSize + spacing),
                            left: (target[1] ~/ 2 + user1[1]) *
                                (cellSize + spacing),
                            width: cellSize,
                            height: cellSize,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Transform.rotate(
                                angle: getRotationAngle(target),
                                child: SvgPicture.asset(
                                  'assets/images/up_circle.svg',
                                ),
                              ),
                            )),

                    // 조건에 따라 GestureDetector 설정
                    if (!gameState.isLose() && gameState.isCurrentTurn(isFirst))
                      GestureDetector(
                        // 비어있는 영역도 터치가 가능하도록 함
                        behavior: HitTestBehavior.opaque,
                        onTapUp: wallTemp.isEmpty
                            ? null
                            : (details) {
                                setState(() {
                                  wallTemp = ""; // wallTemp를 빈 문자열로 지우기
                                });
                              },
                        onPanStart: wallTemp.isEmpty
                            ? (details) {
                                setState(() {
                                  startPoint = details.localPosition;
                                  endPoint = null;
                                });
                              }
                            : null,
                        onPanUpdate: (details) {
                          if (details.localPosition.dx >= 0 &&
                              details.localPosition.dx <= screenWidth - 36 &&
                              details.localPosition.dy >= 0 &&
                              details.localPosition.dy <= screenWidth - 36 &&
                              gameState.getUser1WallCount((isFirst)) > 0) {
                            double distance =
                                (startPoint! - details.localPosition).distance;
                            setState(() {
                              if (distance > 5) {
                                endPoint = details.localPosition;
                              }
                            });
                          }
                        },
                        onPanEnd: wallTemp.isEmpty
                            ? (details) {
                                // startPoint가 null이 아닌지 확인
                                if (startPoint != null) {
                                  if (endPoint == null) {
                                    setPlayer(startPoint!); // 플레이어 설정
                                  } else {
                                    Offset? finalEndPoint =
                                        painter.restrictedEnd;

                                    // finalEndPoint가 null이 아닌지 확인
                                    if (finalEndPoint != null) {
                                      setWallTemp(startPoint!,
                                          finalEndPoint); // 벽 임시 설정
                                    } else {
                                      print('finalEndPoint가 null입니다.');
                                    }
                                  }
                                } else {
                                  print('startPoint가 null입니다.');
                                }

                                setState(() {
                                  startPoint = null;
                                  endPoint = null;
                                });
                              }
                            : null,
                      ),

                    // wall temp 영역
                    Builder(builder: (BuildContext context) {
                      // wallTemp가 빈 문자열이면 아무것도 반환하지 않음
                      if (wallTemp.isEmpty) {
                        return SizedBox.shrink(); // 빈 공간(아무것도 렌더링하지 않음)을 반환
                      }

                      // 처음 문자열이 단일 숫자(True)인지 문자(False)인지 확인함
                      bool isHorizontalWall =
                          wallTemp[0].contains(RegExp(r'[0-9]'));

                      int topCon = isHorizontalWall
                          ? int.parse(wallTemp[0])
                          : int.parse(wallTemp[1]);

                      int leftCon = isHorizontalWall
                          ? wallTemp[1].codeUnitAt(0) - 'A'.codeUnitAt(0)
                          : wallTemp[0].codeUnitAt(0) - 'A'.codeUnitAt(0);

                      final double top = isHorizontalWall
                          ? topCon * cellSize + spacing * (topCon - 1)
                          : (topCon - 1) * (cellSize + spacing);

                      final double left = isHorizontalWall
                          ? leftCon * (cellSize + spacing)
                          : (leftCon + 1) * cellSize + spacing * leftCon;

                      double touchMargin = cellSize / 2;

                      return Positioned(
                          // 터치 영역을 넓히는 마진만큼 제외
                          top: top - (isHorizontalWall ? touchMargin : 0),
                          left: left - (isHorizontalWall ? 0 : touchMargin),
                          child: GestureDetector(
                            // 비어있는 영역도 터치가 가능하도록 함
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setWall();
                            },
                            child: Container(
                              width: isHorizontalWall
                                  ? 2 * cellSize + spacing
                                  : spacing,
                              height: isHorizontalWall
                                  ? spacing
                                  : 2 * cellSize + spacing,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 127, 80)
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              margin: EdgeInsets.only(
                                top: isHorizontalWall ? touchMargin : 0,
                                bottom: isHorizontalWall ? touchMargin : 0,
                                left: isHorizontalWall ? 0 : touchMargin,
                                right: isHorizontalWall ? 0 : touchMargin,
                              ),
                            ),
                          ));
                    }),
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

            Center(
              child: gameState.isLose()
                  ? Container(
                      padding: EdgeInsets.all(16), // 텍스트 주위에 패딩을 추가
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8), // 모서리를 둥글게
                      ),
                      child: Text(
                        gameState.isCurrentTurn(isFirst)
                            ? 'You LOSE'
                            : 'You WIN',
                        style: TextStyle(
                          color: Colors.white, // 텍스트 색상을 흰색으로 설정
                          fontSize: 24, // 텍스트 크기 설정
                          fontWeight: FontWeight.bold, // 텍스트 굵기 설정
                        ),
                        textAlign: TextAlign.center, // 텍스트를 중앙 정렬
                      ),
                    )
                  : Container(), // 아무것도 띄우지 않음
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (socketMessage != null) // 메시지가 있으면 표시
                    Text(
                      socketMessage!,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  // 게임 화면의 나머지 UI 요소들
                ],
              ),
            ),
          ])),
    ]);
  }

  @override
  void dispose() {
    socket.dispose(); // 소켓 연결 종료
    super.dispose(); // 부모 클래스의 dispose 호출
  }
}