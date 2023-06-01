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

double getTranslateYFactorForTextAlignment(TextOffset offset) {
  switch (offset) {
    case TextOffset.above:
      return 1.0;
    case TextOffset.inline:
      return 0.5;
    case TextOffset.below:
      return 0.0;
  }
}
