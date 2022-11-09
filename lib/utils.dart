import 'package:draw_on_path/draw_on_path.dart';
import 'package:flutter/material.dart';

TextPainter getTextPainterFor(
  String text,
  TextStyle textStyle, {
  TextDirection textDirection = TextDirection.ltr,
}) {
  final textSpan = TextSpan(text: text, style: textStyle);
  final textPainter = TextPainter(text: textSpan, textDirection: textDirection);
  textPainter.layout();
  return textPainter;
}

double getTranslateYFactorForTextAlignment(TextAlignment textAlignment) {
  switch (textAlignment) {
    case TextAlignment.up:
      return 0.0;
    case TextAlignment.mid:
      return 0.5;
    case TextAlignment.bottom:
      return 1.0;
  }
}
