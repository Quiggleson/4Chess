import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class DebugOnly extends StatelessWidget {
  const DebugOnly({required this.text, required this.onPress, super.key});

  final String text;
  final Function(BuildContext) onPress;

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: kDebugMode,
        child: TextButton(
          child: Text(text),
          onPressed: () => onPress(context),
        ));
  }
}
