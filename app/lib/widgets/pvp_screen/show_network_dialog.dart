import 'package:flutter/material.dart';

void showNetworkDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('네트워크 오류'),
        content: Text('네트워크 연결이 되어 있지 않습니다. 연결 후 다시 시도하세요.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('확인'),
          ),
        ],
      );
    },
  );
}
