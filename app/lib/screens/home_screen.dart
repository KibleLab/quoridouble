import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quoridouble/utils/ad_helper.dart';
import 'package:quoridouble/widgets/ai_widgets/show_game_setup_dialog.dart';
import 'package:quoridouble/widgets/show_language_dialog.dart';
import 'package:quoridouble/widgets/show_info.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  BannerAd? bannerAd;

  @override
  void initState() {
    super.initState();

    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
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
                showGameInfomation(context);
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
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.22, vertical: 30),
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
                child: GestureDetector(
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
                ),
              ),
            ),
          ),
        ),
      ),
      if (bannerAd != null)
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewPadding.bottom),
            child: SizedBox(
              width: bannerAd!.size.width.toDouble(),
              height: bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: bannerAd!),
            ),
          ),
        ),
    ]);
  }
}
