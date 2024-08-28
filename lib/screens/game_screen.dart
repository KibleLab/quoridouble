import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  List<int> p1pos = [0, 4];
  List<int> p2pos = [8, 4];
  List<String> wall = ["3EF", "D34", "7DE"];
  String wallTemp = "1AB";

  void _play(int row, int col) {
    setState(() {
      p2pos = [row, col];
    });
  }

  void _updateWall() {
    if (wallTemp.isNotEmpty) {
      setState(() {
        wall.add(wallTemp);
        wallTemp = ""; // wallTemp를 빈 문자열로 지우기
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 화면의 전체 너비를 가져오기
    double screenWidth = MediaQuery.of(context).size.width;
    // 화면의 전체 높이를 가져오기
    double screenHeight = MediaQuery.of(context).size.height;

    final double cellSize = (screenWidth - 100) / 9;
    const double spacing = 8;

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
                                print(startPoint);
                                print(endPoint);
                                // wallTemp = "1BC";
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
                        top: p1pos[0] * (cellSize + spacing),
                        left: p1pos[1] * (cellSize + spacing),
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
                        top: p2pos[0] * (cellSize + spacing),
                        left: p2pos[1] * (cellSize + spacing),
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
                              _updateWall();
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
                'Walls 10',
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
                'Walls 10',
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
