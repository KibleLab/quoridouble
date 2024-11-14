import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum MatchDialogState {
  initial,
  loading,
}

class MatchDialog extends StatefulWidget {
  const MatchDialog({
    super.key,
  });

  @override
  State<MatchDialog> createState() => _MatchDialogState();
}

class _MatchDialogState extends State<MatchDialog> {
  MatchDialogState _currentState = MatchDialogState.initial;

  void _handleRandomMatch() {
    setState(() {
      _currentState = MatchDialogState.loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _currentState == MatchDialogState.initial
            ? _buildInitialDialog()
            : _buildLoadingDialog(),
      ),
    );
  }

  Widget _buildInitialDialog() {
    return Column(
      key: const ValueKey('initial'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const DefaultTextStyle(
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          child: Text('PvP 2-way Game'),
        ),
        const SizedBox(height: 20),
        _buildButton('Random Match', _handleRandomMatch),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              side: BorderSide(
                color: Colors.grey.shade400, // 연한 회색 테두리
                width: 2,
              ),
            ),
            onPressed: null, // 비활성화 상태
            child: Text(
              'Invitation Code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400, // 텍스트 색상도 연하게
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingDialog() {
    return Column(
      key: const ValueKey('loading'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const DefaultTextStyle(
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          child: Text('PvP 2-way Game'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          child: Lottie.asset(
            'assets/lotties/splash.json',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        const AnimatedLoadingText(),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          side: const BorderSide(
            color: Colors.black,
            width: 2,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

class AnimatedLoadingText extends StatefulWidget {
  const AnimatedLoadingText({super.key});

  @override
  State<AnimatedLoadingText> createState() => _AnimatedLoadingTextState();
}

class _AnimatedLoadingTextState extends State<AnimatedLoadingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        if (_controller.status == AnimationStatus.completed) {
          _controller.reset();
          setState(() {
            _dotCount = (_dotCount + 1) % 4; // 0에서 3까지 순환
          });
          _controller.forward();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const DefaultTextStyle(
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          child: Text('게임을 찾는중'),
        ),
        SizedBox(
          width: 24, // 점들을 위한 고정된 너비
          child: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            child: Text(
              '.' * _dotCount,
            ),
          ),
        ),
      ],
    );
  }
}
