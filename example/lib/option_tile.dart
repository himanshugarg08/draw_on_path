import 'package:example/main.dart';
import 'package:flutter/material.dart';

class OptionTile extends StatelessWidget {
  final PathType pathType;
  final PathType selectedPathType;
  final ValueChanged<PathType> onChanged;
  const OptionTile({
    super.key,
    required this.pathType,
    required this.selectedPathType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: RadioListTile(
          value: pathType,
          title: Text(
            pathType.name.capitalise,
            style: const TextStyle(color: Colors.white),
          ),
          groupValue: selectedPathType,
          activeColor: Colors.white,
          onChanged: (_) {
            if (_ == null) {
              return;
            }
            onChanged(_);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          tileColor: Colors.white24,
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String get capitalise => "${this[0].toUpperCase()}${substring(1)}";
}
