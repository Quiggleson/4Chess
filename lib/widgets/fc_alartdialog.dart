import 'package:flutter/material.dart';

import '../theme/fc_colors.dart';
import 'fc_button.dart';

class FCAlertDialog extends StatelessWidget {
  const FCAlertDialog({super.key, required this.message, this.actions});

  final String message;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: FCColors.thinBorder, width: 3),
            borderRadius: BorderRadius.circular(15)),
        backgroundColor: FCColors.background,
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
        actionsPadding: const EdgeInsets.all(30),
        title: Expanded(
            child: Container(
                decoration: BoxDecoration(
                    color: FCColors.primaryBlue,
                    borderRadius: BorderRadius.circular(15)),
                child: const Text(
                  'CONFIRM',
                  style: TextStyle(fontSize: 56),
                  textAlign: TextAlign.center,
                ))),
        content: Text(message),
        actions: actions);
  }
}
