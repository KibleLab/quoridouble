import 'package:flutter/material.dart';

void showInfo(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('보드게임 쿼리도의 룰',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '반대편에 먼저 도달하면 승리한다.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '자신의 차례에 두 가지중 하나를 선택한다.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '1. 말 이동하기\n\n',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '- 전후좌우 어디든지 1칸 이동 하지만 벽으로 막혀 있는 경우에는 이동할 수 없다.\n\n'
                '- 본인이 전진하려는 방향으로 상대의 말과 붙어있을 때 해당 말을 건너 뛰고 전진하는 것이 가능\n\n'
                '- 본인이 전진하려는 방향으로 상대의 말과 붙어있을 때 상대의 말 뒤에 벽이 있다면 대각선으로 이동이 가능하다.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '2. 벽 세우기\n\n',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '(단, 상대를 벽으로 둘러 싸서 가두거나 하는 등의 방법으로, 완전히 반대편에 도달할 루트를 없애서는 안 된다.)\n\n',
                style: TextStyle(fontSize: 16),
              ),
              Divider(),
              Text(
                'Quoridouble 설명서\n',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '1. 선공 후공은 랜덤이다.\n\n'
                '2. White는 선공이며, Black은 후공이다.\n\n'
                '3. 하단은 자신이며, 상단은 상대이다.\n\n'
                '4. 자신의 남은 벽 수는 하단에 있다.\n\n'
                '5. 상대의 남은 벽 수는 상단에 있다.\n\n'
                '6. 이동은 화살표 클릭시 이동한다.\n\n'
                '7. 보드영역을 상하 or 좌우로 드래그 시 해당 영역에 반투명 벽이 설치된다.\n\n'
                '8. 반투명 벽이 있는 경우 플레이어의 이동 및 드래그는 비활성화된다.\n\n'
                '9. 반투명 벽 취소는 보드내 다른 영역을 클릭시 사라진다.,\n\n'
                '10 반투명 벽을 한 번 더 클릭시 벽을 설치할 수가 있다.\n\n'
                '모두 사이좋게 플레이하세요.\n\n',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('닫기', style: TextStyle(fontSize: 16)),
          ),
        ],
      );
    },
  );
}
