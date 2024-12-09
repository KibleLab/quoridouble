import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quoridouble/screens/pvp_screen.dart';
import 'package:quoridouble/utils/socket_service.dart';

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

  @override
  void initState() {
    super.initState();
  }

  final SocketService _socketService = SocketService();
  bool isWaiting = false;

  @override
  void dispose() {
    if (isWaiting) {
      _socketService.disconnect();
    }
    super.dispose();
  }

  void startRandomMatch() {
    setState(() => isWaiting = true);

    _socketService.connect();

    _socketService.socket?.on('waiting', (data) {
      // 매칭 대기 중
      print(data);
    });

    _socketService.socket?.on('startGame', (data) {
      isWaiting = false;

      int isFirst = data['isFirst'];
      print("Room ID - ${data['roomId']}");
      print("isFirst - $isFirst");

      // 모달 닫기
      Navigator.of(context).pop();

      // 매칭 성공
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              PvPScreen(isFirst: isFirst, socketService: _socketService),
          transitionDuration: Duration.zero, // 전환 애니메이션 시간 설정
          reverseTransitionDuration: Duration.zero, // 뒤로가기 애니메이션 시간 설정
        ),
      );
    });
  }

  void _handleRandomMatch() {
    setState(() {
      _currentState = MatchDialogState.loading;
    });
    startRandomMatch();
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
        duration: Duration.zero, // 애니메이션 없이 즉시 전환
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
          child: Text('PvP Game'),
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
                color: Colors.grey.shade400,
                width: 2,
              ),
            ),
            onPressed: null,
            child: Text(
              'Invitation Code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400,
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
          child: Text('PvP Game'),
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
        DefaultTextStyle(
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          child: Text('pvp_screen.search').tr(),
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
