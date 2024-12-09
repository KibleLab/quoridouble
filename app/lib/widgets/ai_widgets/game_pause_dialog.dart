import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class GamePauseDialog extends StatelessWidget {
  final VoidCallback onRematch;
  final VoidCallback onExit;

  const GamePauseDialog({
    super.key,
    required this.onRematch,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black, // 테두리 색상
          width: 2, // 테두리 두께
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            child: Text('ai_screen.pause').tr(),
          ),
          const SizedBox(height: 20),
          _buildButton('ai_screen.rematch', onRematch),
          const SizedBox(height: 12),
          _buildButton('ai_screen.exit', onExit),
        ],
      ),
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
            color: Colors.black, // 테두리 색상
            width: 2, // 테두리 두께
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ).tr(),
      ),
    );
  }
}
