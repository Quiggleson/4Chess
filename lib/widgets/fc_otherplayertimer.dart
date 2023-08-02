import 'package:flutter/material.dart';
import 'package:fourchess/util/playerinfo.dart';

import '../theme/fc_colors.dart';
import 'fc_button.dart';
import 'fc_timer.dart';

class OtherPlayerTimer extends StatefulWidget {
  OtherPlayerTimer(
      {super.key,
      required PlayerInfo playerInfo,
      required GameStatus gameStatus})
      : name = playerInfo.name,
        status = playerInfo.status,
        time = playerInfo.time,
        game = gameStatus;

  final String name;
  final PlayerStatus status;
  final double time;
  final GameStatus game;

  @override
  State<OtherPlayerTimer> createState() => OtherPlayerTimerState();
}

class OtherPlayerTimerState extends State<OtherPlayerTimer> {
  final GlobalKey<FCTimerState> _timerState = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (_timerState.currentState != null) {
      if (widget.status == PlayerStatus.turn &&
          widget.game == GameStatus.inProgress) {
        _timerState.currentState!.start();
      } else {
        _timerState.currentState!.stop();

        if (widget.game == GameStatus.starting) {
          _timerState.currentState!.setTime(widget.time);
        }
      }
    }

    return Expanded(
        flex: 1,
        child: Container(
            clipBehavior: Clip.hardEdge,
            height: 180,
            decoration: BoxDecoration(
                color: FCColors.fromPlayerStatus[widget.status],
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.name, style: const TextStyle(fontSize: 32)),
                const Padding(padding: EdgeInsets.only(top: 20)),
                FCTimer(
                    //No events needed here, all events should be updated from the device that this timer represents.
                    enabled: false,
                    key: _timerState,
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

  double getTime() {
    return _timerState.currentState!.getTime();
  }
}
