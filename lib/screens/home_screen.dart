import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quoridouble/screens/pvp_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:quoridouble/widgets/modals/show_game_setup_modal.dart';
import 'package:quoridouble/widgets/modals/show_info.dart';

class HomeScreen extends StatefulWidget {
  final int? page;

  const HomeScreen({super.key, this.page});
  @override
  DraggableContainersState createState() => DraggableContainersState();
}

class DraggableContainersState extends State<HomeScreen> {
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
            showGameSetupModal(context);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/ai_solo.svg',
                semanticsLabel: 'AI Game Icon',
              ),
              Text(
                'AI 2-Way',
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
          onTap: () async {
            final ConnectivityResult connectivityResult =
                await (Connectivity().checkConnectivity());

            if (connectivityResult == ConnectivityResult.wifi ||
                connectivityResult == ConnectivityResult.mobile) {
              // 네트워크에 연결되어 있으면 페이지 이동
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      RoomScreen(),
                  transitionDuration: Duration.zero, // 전환 애니메이션 시간 설정
                  reverseTransitionDuration: Duration.zero, // 뒤로가기 애니메이션 시간 설정
                ),
              );
            } else {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('네트워크 오류'),
                    content: Text('네트워크 연결이 되어 있지 않습니다. 연결 후 다시 시도하세요.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('확인'),
                      ),
                    ],
                  );
                },
              );
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/pvp_2_way.svg',
                semanticsLabel: 'PvP Game Icon',
              ),
              Text(
                'PvP 2-Way',
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
          title: Text(
            "Quoridouble",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          centerTitle: false, // 타이틀을 좌측에 정렬
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline_rounded),
              onPressed: () {
                showInfo(context);
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
              itemCount: 2,
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
