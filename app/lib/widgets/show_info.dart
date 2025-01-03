import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class GameInstructionsPages extends StatefulWidget {
  const GameInstructionsPages({super.key});

  @override
  State<GameInstructionsPages> createState() => _GameInstructionsPagesState();
}

class _GameInstructionsPagesState extends State<GameInstructionsPages> {
  final PageController _pageController = PageController();
  int _currentPage = 1;
  final int _totalPages = 6; // 총 페이지 수

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.toInt() ?? 0;
        _currentPage += 1; // 1부터 시작하도록 조정
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // 모서리를 직각으로 설정
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'info_dialog.info_title',
              style: Theme.of(context).textTheme.titleLarge,
            ).tr(),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: PageView(
                controller: _pageController,
                children: [
                  _buildPage('info_dialog.manual_page1_title', [
                    'info_dialog.manual_page1_contents',
                  ], [
                    'assets/images/info/page1.png',
                  ], [
                    Size(360 * 0.55, 440 * 0.55),
                  ]),
                  _buildPage('info_dialog.manual_page2_title', [
                    'info_dialog.manual_page2_contents',
                  ], [
                    'assets/images/info/page2.png',
                  ], [
                    Size(360 * 0.55, 440 * 0.55),
                  ]),
                  _buildPage('info_dialog.manual_page3_title', [
                    'info_dialog.manual_page3_contents',
                  ], [
                    'assets/images/info/page3.png',
                  ], [
                    Size(360 * 0.55, 440 * 0.55),
                  ]),
                  _buildPage('info_dialog.manual_page4_title', [
                    'info_dialog.manual_page4_contents',
                  ], [
                    'assets/images/info/page4.png',
                  ], [
                    Size(360 * 0.55, 440 * 0.55),
                  ]),
                  _buildPage('info_dialog.manual_page5_title', [
                    'info_dialog.manual_page5_contents_1',
                    'info_dialog.manual_page5_contents_2',
                    'info_dialog.manual_page5_contents_3',
                  ], [
                    'assets/images/info/page5-1.png',
                    'assets/images/info/page5-2.png',
                    'assets/images/info/page5-3.png',
                  ], [
                    Size(200, 200),
                    Size(200, 200),
                    Size(200, 200),
                  ]),
                  _buildPage('info_dialog.manual_page6_title', [
                    'info_dialog.manual_page6_contents_1',
                    'info_dialog.manual_page6_contents_2',
                    'info_dialog.manual_page6_contents_3',
                    'info_dialog.manual_page6_contents_4',
                  ], [
                    'assets/images/info/page6-1.png',
                    'assets/images/info/page6-2.png',
                    'assets/images/info/page6-3.png',
                    'assets/images/info/page6-4.png',
                  ], [
                    Size(200, 200),
                    Size(200, 200),
                    Size(200, 200),
                    Size(200, 200),
                  ]),
                ],
              ),
            ),
            const Text(
              'info_dialog.swipe_guide',
              textAlign: TextAlign.center,
            ).tr(),
            Text(
              'info_dialog.current_page',
              style: const TextStyle(
                fontSize: 14,
              ),
            ).tr(args: ['($_currentPage/$_totalPages)']),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'info_dialog.close',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ).tr(),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildPage(
  String title,
  List<String> descriptions,
  List<String> imagePaths,
  List<Size> imageSizes, // 이미지 크기를 받는 리스트 추가
) {
  return Column(
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center, // 제목 가운데 정렬
      ).tr(),
      const SizedBox(height: 16),
      Expanded(
        child: ListView.builder(
          itemCount: descriptions.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Container(
                  width: double.infinity, // 전체 너비
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    descriptions[index],
                    textAlign: TextAlign.center, // 설명 가운데 정렬
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5, // 줄 간격
                    ),
                  ).tr(),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: imageSizes[index].width, // 개별 이미지 너비
                  height: imageSizes[index].height, // 개별 이미지 높이
                  child: Image.asset(
                    imagePaths[index], // 각 설명에 맞는 이미지 경로
                    fit: BoxFit.cover, // 이미지가 영역에 맞게 조정
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    ],
  );
}

void showGameInfomation(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const GameInstructionsPages(),
  );
}
