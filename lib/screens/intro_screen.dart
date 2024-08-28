import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  AnimatedWidgetState createState() => AnimatedWidgetState();
}

class AnimatedWidgetState extends State<IntroScreen> {
  bool _isMovedRight = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    while (true) {
      // 무한 루프
      await Future.delayed(Duration(seconds: 1));
      if (mounted) setState(() => _isMovedRight = true);
      await Future.delayed(Duration(seconds: 1));
      if (mounted) setState(() => _isMovedRight = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double pi = 3.141592653589793;
    const double cellSize = (180 - 42) / 3;
    const double spacing = 8;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Transform.rotate(
          angle: -45 * pi / 180, // 45도를 라디안으로 변환
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color.fromARGB(255, 107, 49, 54),
                width: 5.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Stack(
              children: [
                GridView.count(
                  physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화
                  crossAxisCount: 3,
                  padding: EdgeInsets.all(8.0),
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  children: List.generate(9, (index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 237, 237, 237),
                        borderRadius: BorderRadius.circular(2.5), // 모서리 반경 설정
                      ),
                    );
                  }),
                ),
                Positioned(
                    top: 0 * (cellSize + spacing) + spacing,
                    left: 1 * (cellSize + spacing) + spacing,
                    width: cellSize,
                    height: cellSize,
                    child: Transform.rotate(
                      angle: 45 * (pi / 180), // 45도를 라디안으로 변환
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SvgPicture.asset(
                          'assets/images/white_pin.svg',
                        ),
                      ),
                    )),
                Positioned(
                    top: 2 * (cellSize + spacing) + spacing,
                    left: 1 * ((180 - 42) / 3 + 8) + 8,
                    width: cellSize,
                    height: cellSize,
                    child: Transform.rotate(
                      angle: 45 * (pi / 180), // 45도를 라디안으로 변환
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SvgPicture.asset(
                          'assets/images/black_pin.svg',
                        ),
                      ),
                    )),
                AnimatedPositioned(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  top: 1 * cellSize + spacing * (1 - 1) + spacing,
                  left: _isMovedRight
                      ? 0 * (cellSize + spacing) + spacing // 왼쪽으로 이동
                      : 1 * (cellSize + spacing) + spacing,
                  child: Container(
                    width: 2 * cellSize + spacing,
                    height: spacing,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 127, 80),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  top: 2 * cellSize + spacing * (2 - 1) + spacing,
                  left: _isMovedRight
                      ? 1 * (cellSize + spacing) + spacing // 오른쪽으로 이동
                      : 0 * (cellSize + spacing) + spacing,
                  child: Container(
                    width: 2 * cellSize + spacing,
                    height: spacing,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 127, 80),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
