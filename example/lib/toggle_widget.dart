import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ToggleWidget extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const ToggleWidget({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(
          width: 20,
        ),
        CupertinoSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}
