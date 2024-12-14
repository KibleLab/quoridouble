import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quoridouble/screens/ai_screen.dart';

void showGameSetupDialog(BuildContext context) {
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
                    'AI Game',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'ai_screen.order',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ).tr(),
                  const SizedBox(height: 8),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final buttonWidth = constraints.maxWidth / 3;
                        return Stack(
                          children: [
                            // 애니메이션되는 선택 배경
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              left: isSelectedOrder * buttonWidth,
                              top: 2,
                              bottom: 2,
                              width: buttonWidth,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border:
                                      Border.all(color: Colors.black, width: 2),
                                ),
                              ),
                            ),
                            // 버튼들
                            Align(
                              alignment: Alignment.center, // 텍스트 세로 정렬
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildOrderButton(
                                      onTap: () =>
                                          setState(() => isSelectedOrder = 0),
                                      value: 0,
                                      label: 'Random',
                                      groupValue: isSelectedOrder),
                                  Container(
                                      width: 1,
                                      height: 16,
                                      color: Colors.grey[400]),
                                  _buildOrderButton(
                                      onTap: () =>
                                          setState(() => isSelectedOrder = 1),
                                      value: 1,
                                      label: 'First',
                                      groupValue: isSelectedOrder),
                                  Container(
                                      width: 1,
                                      height: 16,
                                      color: Colors.grey[400]),
                                  _buildOrderButton(
                                      onTap: () =>
                                          setState(() => isSelectedOrder = 2),
                                      value: 2,
                                      label: 'Last',
                                      groupValue: isSelectedOrder),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ai_screen.difficulty',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ).tr(),
                  const SizedBox(height: 8),
                  Container(
                    height: 120, // 높이 조정
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    alignment: Alignment.center, // 내용 가운데 정렬
                    child: ListWheelScrollView.useDelegate(
                      physics: FixedExtentScrollPhysics(), // 부드러운 스크롤링
                      itemExtent: 40, // 각 항목의 높이
                      onSelectedItemChanged: (index) {
                        setState(() {
                          isSelectedDifficulty = index;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          final labels = [
                            'Level - 1',
                            'Level - 2',
                            'Level - 3',
                            'Level - 4',
                            'Level - 5',
                          ];
                          final isSelected = isSelectedDifficulty == index;

                          return AnimatedContainer(
                            duration:
                                Duration(milliseconds: 300), // 애니메이션 지속 시간
                            curve: Curves.easeInOut, // 부드러운 애니메이션 효과
                            alignment: Alignment.center,
                            margin:
                                EdgeInsets.symmetric(vertical: 2), // 항목 간 간격
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.black.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              labels[index],
                              style: TextStyle(
                                fontSize: isSelected ? 20 : 16, // 선택된 항목 크기 변경
                                color: isSelected
                                    ? Colors.black
                                    : Colors.grey, // 선택된 항목 색상 변경
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                        childCount: 5, // 항목 개수
                      ),
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
                                  AIScreen(
                            level: isSelectedDifficulty + 1,
                            isOrder: isSelectedOrder,
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    child: const Text(
                      'ai_screen.start',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ).tr(),
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
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ),
    ),
  );
}
