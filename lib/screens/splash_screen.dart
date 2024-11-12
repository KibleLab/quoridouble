import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white, // 배경을 흰색으로 설정
      body: Center(
        child: Lottie.asset(
          'assets/lotties/splash.json',
          width: screenWidth * 0.8, // 화면 너비의 80%로 설정
          height: screenHeight * 0.8, // 화면 높이의 80%로 설정
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
