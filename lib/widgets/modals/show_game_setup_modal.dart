import 'package:flutter/material.dart';
import 'package:quoridouble/screens/ai_screen.dart';

void showGameSetupModal(BuildContext context) {
  int isSelectedOrder = 0;
  int isSelectedDifficulty = 0;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: Colors.black, width: 2),
              ),
              padding: const EdgeInsets.all(26.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'AI 2-way Game',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Set Play Order',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        _buildOrderButton(
                            onTap: () => setState(() => isSelectedOrder = 0),
                            value: 0,
                            label: 'Random',
                            groupValue: isSelectedOrder),
                        Container(
                            width: 1, height: 16, color: Colors.grey[400]),
                        _buildOrderButton(
                            onTap: () => setState(() => isSelectedOrder = 1),
                            value: 1,
                            label: 'First',
                            groupValue: isSelectedOrder),
                        Container(
                            width: 1, height: 16, color: Colors.grey[400]),
                        _buildOrderButton(
                            onTap: () => setState(() => isSelectedOrder = 2),
                            value: 2,
                            label: 'Last',
                            groupValue: isSelectedOrder),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Difficulty',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        _buildDifficultyButton(
                            onTap: () =>
                                setState(() => isSelectedDifficulty = 0),
                            value: 0,
                            label: 'Basic',
                            groupValue: isSelectedDifficulty),
                        Container(
                            width: 1, height: 16, color: Colors.grey[400]),
                        _buildDifficultyButton(
                            onTap: () =>
                                setState(() => isSelectedDifficulty = 1),
                            value: 1,
                            label: 'Normal',
                            groupValue: isSelectedDifficulty),
                        Container(
                            width: 1, height: 16, color: Colors.grey[400]),
                        _buildDifficultyButton(
                            onTap: () =>
                                setState(() => isSelectedDifficulty = 2),
                            value: 2,
                            label: 'Hard',
                            groupValue: isSelectedDifficulty),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  QuoridoubleAIScreen(
                            level: isSelectedDifficulty + 1,
                            isOrder: isSelectedOrder,
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    child: const Text(
                      'Game Start!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Widget _buildOrderButton({
  required VoidCallback onTap,
  required int value,
  required String label,
  required int groupValue,
}) {
  final isSelected = groupValue == value;

  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    ),
  );
}

Widget _buildDifficultyButton({
  required VoidCallback onTap,
  required int value,
  required String label,
  required int groupValue,
}) {
  final isSelected = groupValue == value;

  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    ),
  );
}