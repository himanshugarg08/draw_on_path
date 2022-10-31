import 'package:flutter/material.dart';

class Point extends StatefulWidget {
  final Color color;
  final Offset initialPosition;
  final void Function(Offset) onUpdate;
  final Size size;
  const Point({
    super.key,
    required this.color,
    required this.initialPosition,
    required this.onUpdate,
    this.size = const Size(16.0, 16.0),
  });

  @override
  State<Point> createState() => PointState();
}

class PointState extends State<Point> {
  late Offset _offset;

  @override
  void initState() {
    super.initState();
    _offset = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx - widget.size.width / 2,
      top: _offset.dy - widget.size.height / 2,
      child: GestureDetector(
        onPanUpdate: (_) {
          setState(() {
            _offset = _.globalPosition;
          });
          widget.onUpdate(_offset);
        },
        child: Container(
          height: widget.size.height,
          width: widget.size.width,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
