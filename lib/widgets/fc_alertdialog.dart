import 'package:flutter/material.dart';

import '../theme/fc_colors.dart';
import 'fc_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FCAlertDialog extends StatelessWidget {
  const FCAlertDialog(
      {super.key, required this.message, required this.title, this.actions});

  final String message;
  final String title;
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
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 56),
                  textAlign: TextAlign.center,
                ))),
        content: Text(message, textAlign: TextAlign.center),
        actions: actions);
  }

  static void showTerminatedDialog(BuildContext context,
      {bool isHost = false}) {
    String message = isHost
        ? AppLocalizations.of(context)!.gameSuccessfullyEnded
        : AppLocalizations.of(context)!.endedByHost;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => FCAlertDialog(
                message: message,
                title: AppLocalizations.of(context)!.gameOver,
                actions: <Widget>[
                  FCButton(
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                    },
                    child: Text(AppLocalizations.of(context)!.ok),
                  )
                ]));
  }
}
