import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quoridouble/utils/game.dart';
import 'home_screen.dart';

class Quoridouble extends StatefulWidget {
  const Quoridouble({super.key});

  @override
  QuoridoubleState createState() => QuoridoubleState();
}

class QuoridoubleState extends State<Quoridouble> {
  Offset? startPoint;
  Offset? endPoint;

  final String _result = '1 vs 1 Game';
  final int _blockCounter = 9;

  /// ********************************************
  /// game 핵심 속성
  /// ********************************************

  late GameState gameState;
  late int first;
  late List<int> user1;
  late List<int> user2;

  List<String> wall = [];
  String wallTemp = "";

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    gameState = GameState();
    Random random = Random();

    // 랜덤으로 0 또는 1를 선택
    first = random.nextInt(2);

    user1 = gameState.user1Pos(first);
    user2 = gameState.user2Pos(first);
  }

  /// ********************************************

  @override
  Widget build(BuildContext context) {
    // 화면의 전체 너비를 가져오기
    double screenWidth = MediaQuery.of(context).size.width;
    // 화면의 전체 높이를 가져오기
    double screenHeight = MediaQuery.of(context).size.height;

    final double cellSize = (screenWidth - 100) / 9;
    const double spacing = 8;

    /// ********************************************
    /// game 핵심 기능
    /// ********************************************

    if (gameState.isCurrentTurn(1 - first)) {
      setState(() {
        int action = alphaBetaAction(gameState, 1);
        gameState = gameState.next(action);
        user1 = gameState.user1Pos(first);
        user2 = gameState.user2Pos((first));

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

        if (gameState.isLose()) {
          print("Game END");
        }
      });
    }

    void setPlayer(Offset event) {
      // 클릭 위치를 행동으로 변환
      double boundary = cellSize + spacing;
      int x = 2 * (event.dx ~/ boundary); // 가로
      int y = 2 * (event.dy ~/ boundary); // 세로

      if (boundary * ((event.dx ~/ boundary) + 1) - event.dx < 20) {
        x = 2 * (event.dx ~/ boundary) + 1; // 가로
      }

      if (boundary * ((event.dy ~/ boundary) + 1) - event.dy < 20) {
        y = 2 * (event.dy ~/ boundary) + 1; // 세로
      }

      setState(() {
        if (gameState.isCurrentTurn(first)) {
          List legalMove = gameState.legalMoves();

          List<int> target = [y - (user1[0] * 2), x - (user1[1] * 2)];

          bool exists = legalMove.any(
              (element) => element[0] == target[0] && element[1] == target[1]);

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
            user1 = gameState.user1Pos(first);
            user2 = gameState.user2Pos((first));

            if (gameState.isLose()) {
              print("Game END");
            }
          }
        }
      });
    }

    List<int> eventToIndex(Offset event) {
      double boundary = cellSize + spacing;
      int x = 2 * (event.dx ~/ boundary); // 가로
      int y = 2 * (event.dy ~/ boundary); // 세로

      if (boundary * ((event.dx ~/ boundary) + 1) - event.dx < 20) {
        x = 2 * (event.dx ~/ boundary) + 1; // 가로
      }

      if (boundary * ((event.dy ~/ boundary) + 1) - event.dy < 20) {
        y = 2 * (event.dy ~/ boundary) + 1; // 세로
      }

      return [x, y];
    }

    void setWallTemp(Offset start, Offset end) {
      if (gameState.isCurrentTurn(first)) {
        List<int> startPos = eventToIndex(start);
        List<int> endPos = eventToIndex(end);
        if (endPos[1] >= 0 && endPos[1] <= 16) {
          List<int> resultPos = [
            endPos[0] - startPos[0],
            endPos[1] - startPos[1]
          ];
          if (resultPos[0] == 0) {
            // 세로
            if (resultPos[1] == 3) {
              int action = gameState.xyToWallAction(startPos[1], startPos[0]);

              if (gameState.legalActions().contains(action)) {
                String row = String.fromCharCode(
                    64 + startPos[0] ~/ 2 + startPos[0] % 2);
                String col = (startPos[1] ~/ 2 + 1).toString();

                wallTemp = row + col;
              }
            }
            if (resultPos[1] == -3) {
              int action = gameState.xyToWallAction(endPos[1], endPos[0]);

              if (gameState.legalActions().contains(action)) {
                String row =
                    String.fromCharCode(64 + endPos[0] ~/ 2 + endPos[0] % 2);

                String col = (endPos[1] ~/ 2 + 1).toString();

                wallTemp = row + col;
              }
            }
          }
          if (resultPos[1] == 0) {
            // 가로
            if (resultPos[0] == 3) {
              int action = gameState.xyToWallAction(startPos[1], startPos[0]);

              if (gameState.legalActions().contains(action)) {
                setState(() {
                  String col = (startPos[1] ~/ 2 + startPos[1] % 2).toString();
                  String row = String.fromCharCode(65 + startPos[0] ~/ 2);
                  wallTemp = col + row;
                });
              }
            }
            if (resultPos[0] == -3) {
              int action = gameState.xyToWallAction(startPos[1], startPos[0]);

              if (gameState.legalActions().contains(action)) {
                setState(() {
                  String col = (endPos[1] ~/ 2 + endPos[1] % 2).toString();
                  String row = String.fromCharCode(65 + endPos[0] ~/ 2);
                  wallTemp = col + row;
                });
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

        setState(() {
          int action = gameState.xyToWallAction(x, y);
          gameState = gameState.next(action);
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
            title: Text(_result),
            backgroundColor: Colors.transparent,
            centerTitle: false, // 타이틀을 좌측에 정렬
            actions: [
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
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
                      painter: LinePainter(startPoint, endPoint),
                    ),
                    // 전체 영역에 대한 GestureDetector
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
                          setState(() {
                            endPoint = details.localPosition;
                          });
                        },
                        onPanEnd: wallTemp.isEmpty
                            ? (details) {
                                if (endPoint == null) {
                                  setPlayer(startPoint!);
                                } else {
                                  setWallTemp(startPoint!, endPoint!);
                                }

                                setState(() {
                                  startPoint = null;
                                  endPoint = null;
                                });
                              }
                            : null),
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
                            'assets/images/white_pin.svg',
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
                            'assets/images/black_pin.svg',
                          ),
                        )),

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

                      return Positioned(
                          // 터치 영역을 넓히는 마진만큼 제외
                          top: top - cellSize,
                          left: left - cellSize,
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
                              margin:
                                  EdgeInsets.all(cellSize), // 터치 영역을 넓히는 마진 추가
                            ),
                          ));
                    }),
                  ],
                ),
              ),
            ),
            // 좌측 상단
            Positioned(
              left: 10,
              top: (screenHeight - screenWidth) / 2 - 21 - cellSize - 18 - 12,
              child: Text(
                'Walls ${gameState.getUser2WallCount((first))}',
                style: TextStyle(
                  fontSize: 18,
                  color: const Color.fromARGB(255, 255, 0, 0),
                ),
              ),
            ),
            // 우측 상단
            Positioned(
              right: 10,
              top: (screenHeight - screenWidth) / 2 - 21 - cellSize - 18 - 12,
              child: Text(
                '00:10',
                style: TextStyle(
                  fontSize: 18,
                  color: const Color.fromARGB(255, 255, 0, 0),
                ),
              ),
            ),
            // 좌측 하단
            Positioned(
              left: 10,
              bottom:
                  (screenHeight - screenWidth) / 2 - 21 - cellSize - 18 - 12,
              child: Text(
                '00:10',
                style: TextStyle(
                  fontSize: 18,
                  color: const Color.fromARGB(255, 255, 0, 0),
                ),
              ),
            ),
            //  좌측 상단
            Positioned(
              right: 10,
              bottom:
                  (screenHeight - screenWidth) / 2 - 21 - cellSize - 18 - 12,
              child: Text(
                'Walls ${gameState.getUser1WallCount(first)}',
                style: TextStyle(
                  fontSize: 18,
                  color: const Color.fromARGB(255, 255, 0, 0),
                ),
              ),
            ),
          ])),
    ]);
  }
}

class LinePainter extends CustomPainter {
  final Offset? start;
  final Offset? end;

  LinePainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    if (start != null && end != null) {
      final paint = Paint()
        ..color = Color.fromARGB(255, 255, 127, 80).withOpacity(0.5)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(start!, end!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
