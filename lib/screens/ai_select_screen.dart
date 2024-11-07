import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quoridouble/screens/ai_screen.dart';
import 'package:quoridouble/screens/home_screen.dart';

class AISelectScreen extends StatefulWidget {
  final int? page;

  const AISelectScreen({super.key, this.page});
  @override
  DraggableContainersState createState() => DraggableContainersState();
}

class DraggableContainersState extends State<AISelectScreen> {
  late PageController _pageController;

  // 현재 페이지 값 추적
  late double _currentPageValue;

  // PageController는 내부적으로 리소스를 사용하므로,
  // 위젯이 제거될 때 이를 명시적으로 해제해야 함.
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // page가 null일 경우 0으로 초기화
    _currentPageValue = (widget.page ?? 0).toDouble();

    // 0.6은 각 페이지가 뷰포트의 60%를 차지한다는 의미
    // 양옆으로 이전/다음 페이지의 20%씩이 보이게 된다
    _pageController = PageController(
      viewportFraction: 0.6,
      initialPage: widget.page ?? 0, // 초기 페이지 설정
    );

    _pageController.addListener(() {
      setState(() {
        _currentPageValue = _pageController.page!;
      });
    });
  }

  Widget _buildContainer(int index) {
    switch (index) {
      case 0:
        return GestureDetector(
          // 비어있는 영역도 터치가 가능하도록 함
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => QuoridoubleAIScreen(level: 1)),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/ai_solo.svg',
                semanticsLabel: 'AI Game Icon',
              ),
              Text(
                'CPU Level 1',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      case 1:
        return GestureDetector(
          // 비어있는 영역도 터치가 가능하도록 함
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => QuoridoubleAIScreen(level: 2)),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/ai_solo.svg',
                semanticsLabel: 'AI Game Icon',
              ),
              Text(
                'CPU Level 2',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      case 2:
        return GestureDetector(
          // 비어있는 영역도 터치가 가능하도록 함
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => QuoridoubleAIScreen(level: 3)),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/ai_solo.svg',
                semanticsLabel: 'AI Game Icon',
              ),
              Text(
                'CPU Level 3',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Stack(children: <Widget>[
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background-red.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Select CPU Level"),
          backgroundColor: Colors.transparent,
          centerTitle: false, // 타이틀을 좌측에 정렬
          actions: [
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(page: 1)),
                );
              },
            )
          ],
        ),
        body: Center(
          child: SizedBox(
            width: screenWidth,
            height: screenWidth,
            child: PageView.builder(
              controller: _pageController,
              itemCount: 3,
              itemBuilder: (context, index) {
                double diff = (index - _currentPageValue).abs();
                double scale = 1 - (diff * 0.3).clamp(0.0, 0.3);

                return Transform.scale(
                  scale: scale,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                    child: Container(
                      width: 200,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black, // 테두리 색상
                          width: 3.0, // 테두리 두께
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: _buildContainer(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      )
    ]);
  }
}
