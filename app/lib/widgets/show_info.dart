import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

void showInfo(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // 모서리를 직각으로 설정
        ),
        title: Text(
          'info_dialog.info_title',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ).tr(),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('info_dialog.quoridouble_rule'),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                tr('info_dialog.victory_condition'),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                tr('info_dialog.turn_choice'),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                tr('info_dialog.move_piece'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              for (int i = 1; i <= 3; i++) ...[
                Text(
                  tr('info_dialog.move_piece_details_$i'),
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8), // 각 항목 사이에 간격 추가
              ],
              SizedBox(height: 16),
              Text(
                tr('info_dialog.place_wall'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ...tr('info_dialog.place_wall_details')
                  .split('\n')
                  .map((line) => Text(
                        line,
                        style: TextStyle(fontSize: 16),
                      )),
              Divider(),
              Text(
                tr('info_dialog.quoridouble_manual'),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              for (int i = 1; i <= 9; i++) ...[
                Text(
                  tr('info_dialog.manual_item_$i'),
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8), // 각 항목 사이에 간격 추가
              ],
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'info_dialog.close',
              style: TextStyle(fontSize: 16),
            ).tr(),
          ),
        ],
      );
    },
  );
}
