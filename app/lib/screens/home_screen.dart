import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quoridouble/widgets/ai_widgets/show_game_setup_dialog.dart';
import 'package:quoridouble/widgets/pvp_widgets/match_dialog.dart';
import 'package:quoridouble/widgets/pvp_widgets/show_network_dialog.dart';
import 'package:quoridouble/widgets/show_language_dialog.dart';
import 'package:quoridouble/widgets/show_info.dart';

class HomeScreen extends StatefulWidget {
  final int? page;
  final bool? opponentDisconnected;

  const HomeScreen({super.key, this.page, this.opponentDisconnected});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;

  // 현재 페이지 값 추적
  late double _currentPageValue;
  late bool? opponentDisconnected = widget.opponentDisconnected;
  late FToast fToast;

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

    fToast = FToast();
    fToast.init(context);

    if (opponentDisconnected == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 페이지가 로드된 후에 모달을 띄움
        showOpponentOutToast();
      });
    }

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

  showOpponentOutToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: const Color(0xFF767680),
      ),
      child: const Text(
        "Opponent is out!",
        style: TextStyle(
          color: Colors.white, // 텍스트 색상을 화이트로 설정
        ),
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 3),
    );
  }

  Widget _buildContainer(int index) {
    switch (index) {
      case 0:
        return GestureDetector(
          // 비어있는 영역도 터치가 가능하도록 함
          behavior: HitTestBehavior.opaque,
          onTap: () {
            showGameSetupDialog(context);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/ai_solo.svg',
                semanticsLabel: 'AI Game Icon',
              ),
              Text(
                'AI Game',
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
            final List<ConnectivityResult> connectivityResult =
                await (Connectivity().checkConnectivity());

            if (!mounted) return;

            if (connectivityResult.contains(ConnectivityResult.mobile) ||
                connectivityResult.contains(ConnectivityResult.wifi)) {
              showDialog(
                context: context,
                builder: (context) => Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.8,
                    child: MatchDialog(),
                  ),
                ),
              );
            } else {
              showNetworkDialog(context);
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
                'PvP Game',
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
            ),
            IconButton(
              icon: Icon(Icons.public_rounded), // 지구본 아이콘
              onPressed: () {
                showLanguageDialog(context);
              },
            ),
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
