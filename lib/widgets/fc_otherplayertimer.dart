import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../util/gamestate.dart';
import '../util/player.dart';
import '../theme/fc_colors.dart';
import 'fc_button.dart';
import 'fc_timer.dart';

class OtherPlayerTimer extends StatefulWidget {
  OtherPlayerTimer(
      {super.key,
      required GlobalKey<FCTimerState> timerState,
      required Player playerInfo,
      required GameStatus gameStatus})
      : name = playerInfo.name,
        status = playerInfo.status,
        time = playerInfo.time,
        game = gameStatus,
        timer = timerState;

  final String name;
  final PlayerStatus status;
  final double time;
  final GameStatus game;
  final GlobalKey<FCTimerState> timer;

  @override
  State<OtherPlayerTimer> createState() => OtherPlayerTimerState();
}

class OtherPlayerTimerState extends State<OtherPlayerTimer> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 1,
        child: Container(
            clipBehavior: Clip.hardEdge,
            height: 140 + MediaQuery.of(context).viewPadding.top,
            decoration: BoxDecoration(
                color: FCColors.fromPlayerStatus[widget.status],
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(
                  widget.name,
                  style: const TextStyle(fontSize: 32),
                  maxLines: 1,
                ),
                FCTimer(
                    //No events needed here, all events should be updated from the device that this timer represents.
                    running: widget.status == PlayerStatus.turn,
                    enabled: false,
                    key: widget.timer,
                    initialTime: widget.time,
                    style: FCButton.styleFrom(
                        disabledForegroundColor: Colors.black,
                        backgroundColor:
                            FCColors.fromPlayerStatus[widget.status],
                        disabledBackgroundColor:
                            FCColors.fromPlayerStatus[widget.status],
                        textStyle: const TextStyle(fontSize: 32),
                        minimumSize: const Size.fromHeight(60)))
              ],
            )));
  }
}
