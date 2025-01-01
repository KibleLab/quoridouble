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
              '게임 설명서',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: PageView(
                controller: _pageController,
                children: [
                  _buildPage('쿼리도', [
                    '체스와 같은 턴제 \n추상전략 게임입니다.',
                  ], [
                    'assets/images/info/page1.png',
                  ], [
                    Size(360 * 0.55, 440 * 0.55),
                  ]),
                  _buildPage('승리조건', [
                    '자신의 말을 반대편으로 먼저 \n옮기는 사람이 승리합니다.',
                  ], [
                    'assets/images/info/page2.png',
                  ], [
                    Size(360 * 0.55, 440 * 0.55),
                  ]),
                  _buildPage('게임구성', [
                    '서로에게 각각 말 1개와 \n벽 10개가 주어집니다.',
                  ], [
                    'assets/images/info/page3.png',
                  ], [
                    Size(360 * 0.55, 440 * 0.55),
                  ]),
                  _buildPage('진행방법', [
                    '말을 이동시키거나 \n벽을 설치하면 됩니다.',
                  ], [
                    'assets/images/info/page4.png',
                  ], [
                    Size(360 * 0.55, 440 * 0.55),
                  ]),
                  _buildPage('이동방법', [
                    '(기본) 상하좌우로 한칸 \n움직입니다.',
                    '(상대의 말과 붙어있을 때) \n해당 말을 건너 뛰고 전진합니다.',
                    '(상대의 말을 건너뛸 때) \n상대의 말 뒤에 벽이 있다면 \n대각선으로 이동합니다.',
                  ], [
                    'assets/images/info/page5-1.png',
                    'assets/images/info/page5-2.png',
                    'assets/images/info/page5-3.png',
                  ], [
                    Size(200, 200),
                    Size(200, 200),
                    Size(200, 200),
                  ]),
                  _buildPage('벽설치 방법', [
                    '보드영역을 상하 or 좌우로 \n드래그해서 임시 벽을 설치합니다.',
                    '임시 벽을 한 번 더 클릭해 \n벽을 설치합니다.',
                    '임시 벽 취소는 보드내 \n다른 영역을 클릭시 사라집니다.',
                    '상대나 자신이 반대편으로 도달할 \n루트를 없애서는 안 됩니다.',
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
            const Text('옆으로 스와이프하여 다음 페이지로 이동'),
            Text(
              '현재 페이지 ($_currentPage/$_totalPages)',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
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
                '닫기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
      ),
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
                  ),
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
    builder: (context) => const GameInstructionsPages(),
  );
}
