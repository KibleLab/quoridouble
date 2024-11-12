import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quoridouble/screens/splash_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  // 위젯 시스템이 초기화되었는지 보장
  WidgetsFlutterBinding.ensureInitialized();

  // Set portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 상단바 숨기기
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom]);

  // Run app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          textTheme: TextTheme(
            bodyLarge: TextStyle(fontFamily: 'Verdana'),
            bodyMedium: TextStyle(fontFamily: 'Verdana'),
            displayLarge: TextStyle(fontFamily: 'Verdana'),
            displayMedium: TextStyle(fontFamily: 'Verdana'),
            displaySmall: TextStyle(fontFamily: 'Verdana'),
            headlineMedium: TextStyle(fontFamily: 'Verdana'),
            headlineSmall: TextStyle(fontFamily: 'Verdana'),
            titleLarge: TextStyle(fontFamily: 'Verdana'),
            titleMedium: TextStyle(fontFamily: 'Verdana'),
            titleSmall: TextStyle(fontFamily: 'Verdana'),
            labelLarge: TextStyle(fontFamily: 'Verdana'),
            bodySmall: TextStyle(fontFamily: 'Verdana'),
            labelSmall: TextStyle(fontFamily: 'Verdana'),
          ),
        ),
        // Remove the debug banner
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
          future: Future.delayed(
              const Duration(seconds: 1), () => "Intro Completed."),
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
    return const SplashScreen();
  }
}
