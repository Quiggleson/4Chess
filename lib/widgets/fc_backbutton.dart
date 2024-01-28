import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FCBackButton extends StatelessWidget {
  const FCBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return BackButton(onPressed: () {
      if (onPressed != null) onPressed!();
      Navigator.maybePop(context);
    });
  }
}
