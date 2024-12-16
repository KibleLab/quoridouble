import 'dart:math';

import 'package:flutter/material.dart';

class WallPlacementPainter extends CustomPainter {
  final Offset? start;
  final Offset? end;
  final double cellSize;
  final double spacing;
  Offset? restrictedEnd;

  WallPlacementPainter(this.start, this.end, this.cellSize, this.spacing);

  @override
  void paint(Canvas canvas, Size size) {
    if (start != null && end != null) {
      final paint = Paint()
        ..color = Color.fromARGB(255, 255, 127, 80).withOpacity(0.5)
        ..strokeWidth = spacing
        ..strokeCap = StrokeCap.round;

      // maxLength
      final maxLength = cellSize * 2;

      final dx = end!.dx - start!.dx;
      final dy = end!.dy - start!.dy;

      if (dx.abs() > dy.abs()) {
        // 가로 방향
        double length = min(dx.abs(), maxLength);
        restrictedEnd = Offset(start!.dx + length * dx.sign, start!.dy);
      } else {
        // 세로 방향
        double length = min(dy.abs(), maxLength);
        restrictedEnd = Offset(start!.dx, start!.dy + length * dy.sign);
      }

      canvas.drawLine(start!, restrictedEnd!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
