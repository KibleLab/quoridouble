import 'package:flutter/material.dart';
import 'package:quoridouble/screens/game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  DraggableContainersState createState() => DraggableContainersState();
}

class DraggableContainersState extends State<HomeScreen> {
  // 0.6은 각 페이지가 뷰포트의 60%를 차지한다는 의미
  // 양옆으로 이전/다음 페이지의 20%씩이 보이게 된다
  final PageController _pageController = PageController(viewportFraction: 0.6);

  // 현재 페이지 값 추적
  double _currentPageValue = 0.0;

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
    _pageController.addListener(() {
      setState(() {
        _currentPageValue = _pageController.page!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Stack(children: <Widget>[
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Quoridoble"),
          backgroundColor: Colors.transparent,
          centerTitle: false, // 타이틀을 좌측에 정렬
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Quoridouble()),
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
                      child: Center(
                        child: Text(
                          'Container ${index + 1}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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