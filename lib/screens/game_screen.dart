import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart';

class Quoridouble extends StatefulWidget {
  const Quoridouble({super.key});

  @override
  QuoridoubleState createState() => QuoridoubleState();
}

class QuoridoubleState extends State<Quoridouble> {
  final String _result = '1 vs 1 Game';

  final int _blockCounter = 9;
  List<int> p1pos = [0, 4];
  List<int> p2pos = [8, 4];
  List<String> wall = ["3EF", "D34", "7DE"];

  void _play(int row, int col) {
    setState(() {
      p2pos = [row, col];
    });
  }

  @override
  Widget build(BuildContext context) {
    // 화면의 전체 너비를 가져오기
    double screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background.png"),
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
                icon: Icon(Icons.menu),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
              )
            ],
          ),
          body: Center(
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
                padding: EdgeInsets.all(8.0), // 내부 여백
                child: Stack(
                  children: [
                    Center(
                      child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화
                        shrinkWrap: true, // 그리드의 크기를 내용에 맞춤
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          // 세로 스크롤 그리드에서는 열 수를, 가로 스크롤 그리드에서는 행 수를 의미
                          crossAxisCount: _blockCounter,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: _blockCounter * _blockCounter,
                        // 각 그리드 아이템을 어떻게 build할지 정의하는 함수
                        itemBuilder: (context, index) {
                          int row = index ~/ _blockCounter;
                          int col = index % _blockCounter;
                          return GestureDetector(
                            onTap: () {
                              _play(row, col);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 237, 237, 237),
                                borderRadius:
                                    BorderRadius.circular(2.5), // 모서리 반경 설정
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    for (String wallInfo in wall)
                      Builder(builder: (BuildContext context) {
                        final double cellSize = (screenWidth - 100) / 9;
                        const double spacing = 8;
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
                        top: p1pos[0] * ((screenWidth - 100) / 9 + 8),
                        left: p1pos[1] * ((screenWidth - 100) / 9 + 8),
                        width: (screenWidth - 100) / 9,
                        height: (screenWidth - 100) / 9,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/images/white_pin.svg',
                          ),
                        )),
                    AnimatedPositioned(
                        duration: Duration(milliseconds: 500), // 애니메이션 지속 시간
                        curve: Curves.easeInOut, // 애니메이션 곡선
                        top: p2pos[0] * ((screenWidth - 100) / 9 + 8),
                        left: p2pos[1] * ((screenWidth - 100) / 9 + 8),
                        width: (screenWidth - 100) / 9,
                        height: (screenWidth - 100) / 9,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/images/black_pin.svg',
                          ),
                        ))
                  ],
                )),
          ),
        ),
      ],
    );
  }
}
