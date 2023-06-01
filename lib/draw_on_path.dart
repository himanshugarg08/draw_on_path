library draw_on_path;

import 'dart:math';

import 'package:draw_on_path/utils.dart';
import 'package:flutter/material.dart';

enum TextOffset { above, inline, below }

extension DrawOnPath on Canvas {
  /// draws [text] on [path] with [textStyle]
  ///
  /// It will clip [text] if it cannot fit itself in [path] for given [textStyle]
  ///
  /// [letterSpacing] is the space between 2 letters
  ///
  /// [letterSpacing] has no effect if [autoSpacing] is [true]
  ///
  /// [autoSpacing] will distribute your letters evenly
  ///
  /// Set [isClosed] to [true] if [path] is closed. This will put extra space at the end.
  /// [isClosed] has no effects if [autoSpacing] is [false]

  void drawTextOnPath(
    String text,
    Path path, {
    TextStyle textStyle = const TextStyle(),
    double letterSpacing = 0.0,
    bool isClosed = false,
    bool reorient = true,
    EdgeInsets padding = EdgeInsets.zero,
    TextDirection textDirection = TextDirection.ltr,
    TextOffset textOffset = TextOffset.inline,
    TextAlign textAlign = TextAlign.center,
  }) {
    if (text.isEmpty) {
      return;
    }

    final pathMetricsList = path.computeMetrics().toList();
    final textSize = getTextPainterFor(
      text,
      textStyle,
      textDirection: textDirection,
    ).size;


    var totalLength = 0.0;
    for (var metric in path.computeMetrics()) {
      totalLength += metric.length;
    }

    bool flip = false;
    var reorientedOffset = textOffset;
    final available = totalLength - textSize.width - padding.horizontal;
    if (pathMetricsList.length == 1 && reorient && textOffset != TextOffset.inline) {
      final f = pathMetricsList.first.getTangentForOffset(0)!.position;
      final l = pathMetricsList.last.getTangentForOffset(totalLength - 1)!.position;
      if (l.dx < f.dx) {
        flip = true;
      }
    }

    int currentMetric = 0;
    double currDist = padding.left;
    switch (textAlign) {
      case TextAlign.start:
      case TextAlign.left:
        break;
      case TextAlign.center:
        currDist = available / 2;
        break;
      case TextAlign.end:
      case TextAlign.right:
        currDist = available;
        // TODO: Handle this case.
        break;
      case TextAlign.justify:
        if (text.length > 1) {
          final chars = isClosed ? (text.length) : (text.length - 1);
          letterSpacing = (totalLength - textSize.width) / chars;
        }
        break;
    }
    if (flip) {
      text = text.characters.toList().reversed.join();
    }

    for (int i = 0; i < text.length; i++) {
      final textPainter = getTextPainterFor(
        text[i],
        textStyle,
        textDirection: textDirection,
      );
      final charSize = textPainter.size;

      final tangent = pathMetricsList[currentMetric].getTangentForOffset(currDist + charSize.width / 2)!;
      final currLetterPos = tangent.position;
      final currLetterAngle = tangent.angle + (flip ? pi : 0);

      save();
      translate(currLetterPos.dx, currLetterPos.dy);
      rotate(-currLetterAngle);
      textPainter.paint(
        this,
        currLetterPos
            .translate(
              -currLetterPos.dx,
              -currLetterPos.dy,
            )
            .translate(
              -charSize.width * 0.5,
              -charSize.height * getTranslateYFactorForTextAlignment(reorientedOffset),
            ),
      );
      restore();
      currDist += charSize.width + letterSpacing;

      if (currDist > pathMetricsList[currentMetric].length) {
        currDist = 0;
        currentMetric++;
      }

      if (currentMetric == pathMetricsList.length) {
        break;
      }
    }
  }

  /// draws pattern defined in [drawElementAt] along [path].
  ///
  /// [index] can be used to draw different element at different position based on some logic.
  ///
  /// Use [canvas] to draw anything at [position].
  /// The next [position] is calculated based on [spacing] provided.

  /// [spacing] should be greater than [0].
  /// Ideally [spacing] [=] element width [+] spacing between two elements
  /// (spacing between starting points of two consecutive elements)

  void drawOnPath(
    Path path,
    void Function(int index, Canvas canvas, Offset position) drawElementAt, {
    required double spacing,
  }) {
    assert(spacing > 0);

    if (spacing <= 0) {
      return;
    }

    final pathMetrics = path.computeMetrics();
    final pathMetricsList = pathMetrics.toList();

    int currentMetric = 0;
    int index = 0;

    while (currentMetric < pathMetricsList.length) {
      final currMetricLength = pathMetricsList[currentMetric].length;
      for (double d = 0.0; d < currMetricLength; d += spacing) {
        final tangent = pathMetricsList[currentMetric].getTangentForOffset(d)!;
        final currPos = tangent.position;
        final currAngle = tangent.angle;

        save();
        translate(currPos.dx, currPos.dy);
        rotate(-currAngle);

        drawElementAt(index, this, currPos.translate(-currPos.dx, -currPos.dy));
        index++;

        restore();
      }
      currentMetric++;
    }
  }
}
