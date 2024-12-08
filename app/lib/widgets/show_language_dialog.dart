import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

void showLanguageDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // 모서리를 직각으로 설정
        ),
        title: Text('Select Language'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('English'),
              onTap: () {
                context.setLocale(Locale('en', 'US'));
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('日本語'),
              onTap: () {
                context.setLocale(Locale('ja', 'JP'));
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('한국어'),
              onTap: () {
                context.setLocale(Locale('ko', 'KR'));
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Россия'),
              onTap: () {
                context.setLocale(Locale('ru', 'RU'));
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('中文'),
              onTap: () {
                context.setLocale(Locale('zh', 'CN'));
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}
