import 'package:example/option_tile.dart';
import 'package:example/point_widget.dart';
import 'package:example/toggle_widget.dart';
import 'package:flutter/material.dart';
import 'package:draw_on_path/draw_on_path.dart';

enum PathType { simple, shape, nonContinuous }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Draw on Path',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Path path = Path();

  String text = "Flutter is awesome";
  double letterSpacing = 0.0;

  late Offset left;
  late Offset right;
  late Offset top;
  late Offset bottom;

  bool showPath = false;
  bool autoSpacing = false;
  bool isClosed = false;
  bool textOrPattern = false;

  PathType pathType = PathType.simple;

  void updatePath() {
    path = Path();
    path.moveTo(left.dx, left.dy);
    path.cubicTo(top.dx, top.dy, bottom.dx, bottom.dy, right.dx, right.dy);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    left = Offset(width / 4, height / 2);
    right = Offset(3 * width / 4, height / 2);
    top = Offset(width / 2, height / 4);
    bottom = Offset(width / 2, 3 * height / 4);
    updatePath();
  }

  void onChangedPathType(PathType type) {
    setState(() {
      pathType = type;
    });
    final size = MediaQuery.of(context).size;
    initPath(size);
  }

  void initPath(Size size) {
    switch (pathType) {
      case PathType.simple:
        updatePath();
        break;
      case PathType.shape:
        path = Path();
        path.addOval(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: 200));
        break;
      case PathType.nonContinuous:
        path = Path();

        const value = 100.0;

        path.moveTo(left.dx, left.dy - value);
        path.cubicTo(top.dx, top.dy, bottom.dx, bottom.dy, right.dx, right.dy - value);

        path.moveTo(left.dx, value + left.dy);
        path.lineTo(right.dx, value + right.dy);

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (pathType == PathType.simple) ...[
            Point(
              color: Colors.white,
              initialPosition: left,
              onUpdate: (_) {
                setState(() {
                  left = _;
                });
                updatePath();
              },
            ),
            Point(
              color: Colors.white,
              initialPosition: right,
              onUpdate: (_) {
                setState(() {
                  right = _;
                });
                updatePath();
              },
            ),
            Point(
              color: Colors.red,
              initialPosition: top,
              onUpdate: (_) {
                setState(() {
                  top = _;
                });
                updatePath();
              },
            ),
            Point(
              color: Colors.red,
              initialPosition: bottom,
              onUpdate: (_) {
                setState(() {
                  bottom = _;
                });
                updatePath();
              },
            )
          ],
          IgnorePointer(
            child: CustomPaint(
              painter: DrawOnPathPainter(
                path,
                showPath,
                autoSpacing,
                isClosed,
                letterSpacing,
                text,
                textOrPattern,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: "Enter Text",
                              hintStyle: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            onChanged: (_) {
                              setState(() {
                                text = _;
                              });
                            },
                          ),
                        ),
                        Slider(
                          value: letterSpacing,
                          min: -20,
                          max: 80,
                          onChanged: (_) {
                            setState(() {
                              letterSpacing = _;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...PathType.values.map(
                              (type) => OptionTile(
                                pathType: type,
                                selectedPathType: pathType,
                                onChanged: onChangedPathType,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 100),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        ToggleWidget(
                          label: "Show Path",
                          value: showPath,
                          onChanged: (value) {
                            setState(() {
                              showPath = value;
                            });
                          },
                        ),
                        ToggleWidget(
                          label: "Auto Spacing",
                          value: autoSpacing,
                          onChanged: (value) {
                            setState(() {
                              autoSpacing = value;
                            });
                          },
                        ),
                        ToggleWidget(
                          label: "Is Closed",
                          value: isClosed,
                          onChanged: (value) {
                            setState(() {
                              isClosed = value;
                            });
                          },
                        ),
                        ToggleWidget(
                          label: "Path/Pattern",
                          value: textOrPattern,
                          onChanged: (value) {
                            setState(() {
                              textOrPattern = value;
                            });
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class DrawOnPathPainter extends CustomPainter {
  final Path path;
  final bool showPath;
  final bool autoSpacing;
  final bool isClosed;
  final double letterSpacing;
  final String text;
  final bool textOrPattern;
  DrawOnPathPainter(
    this.path,
    this.showPath,
    this.autoSpacing,
    this.isClosed,
    this.letterSpacing,
    this.text,
    this.textOrPattern,
  );

  final whitePaint = Paint()
    ..color = Colors.white38
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    if (showPath) {
      canvas.drawPath(path, whitePaint);
    }

    if (textOrPattern) {
      canvas.drawOnPath(path, _drawAtElement, spacing: letterSpacing == 0 ? 70 : letterSpacing);
    } else {
      canvas.drawTextOnPath(
        text,
        path,
        textStyle: const TextStyle(fontSize: 28, color: Colors.white),
        autoSpacing: autoSpacing,
        isClosed: isClosed,
        letterSpacing: letterSpacing,
      );
    }
  }

  void _drawAtElement(int index, Canvas canvas, Offset position) {
    final patternPosition = index % 3;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    switch (patternPosition) {
      case 0:
        canvas.drawCircle(position.translate(0, -16), 16, paint);
        break;
      case 1:
        final path = Path();
        path.moveTo(-16, 0);
        path.relativeLineTo(32, 0);
        path.relativeLineTo(-16, -16 * 1.73);
        path.relativeLineTo(-16, 16 * 1.73);
        canvas.drawPath(path, paint);
        break;
      case 2:
        canvas.drawRect(Rect.fromCircle(center: position.translate(0, -16), radius: 16), paint);
        break;
    }
  }

  @override
  bool shouldRepaint(DrawOnPathPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(DrawOnPathPainter oldDelegate) => false;
}
