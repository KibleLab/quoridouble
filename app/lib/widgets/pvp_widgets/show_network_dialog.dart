import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

void showNetworkDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('net_err.title').tr(),
        content: Text('net_err.content').tr(),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('net_err.OK').tr(),
          ),
        ],
      );
    },
  );
}
