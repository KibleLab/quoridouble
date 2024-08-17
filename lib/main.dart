import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quoridouble/screens/intro_screen.dart';
import 'screens/home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 상단바 숨기기
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);

    // Set portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
        // Remove the debug banner
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
          future: Future.delayed(
              const Duration(seconds: 3), () => "Intro Completed."),
          builder: (context, snapshot) {
            return AnimatedSwitcher(
                duration: const Duration(milliseconds: 1000),
                child: _splashLoadingWidget(snapshot));
          },
        ));
  }
}

Widget _splashLoadingWidget(AsyncSnapshot<Object?> snapshot) {
  if (snapshot.hasError) {
    return const Text("Error!!");
  } else if (snapshot.hasData) {
    return const HomeScreen();
  } else {
    return const IntroScreen();
  }
}
