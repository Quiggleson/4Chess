import 'package:flutter/material.dart';
import 'package:fourchess/theme/fc_colors.dart';
import 'package:fourchess/widgets/fc_alartdialog.dart';
import 'package:fourchess/widgets/fc_button.dart';
import 'package:fourchess/widgets/fc_timer.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:async';
import '../backend/client.dart';
import '../util/gamestate.dart';
import '../util/player.dart';
import '../widgets/fc_otherplayertimer.dart';

class Game extends StatefulWidget {
  const Game(
      {super.key, required this.client, required this.id, this.isHost = false});

  final Client client;
  final bool isHost;
  final int id;

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  late GameState gameState;
  late GameStatus gameStatus;
  late List<Player> rotatedPlayers;
  late List<GlobalKey<FCTimerState>> timerKeys;

  @override
  void initState() {
    super.initState();

    rotatedPlayers = _rotateArrayAroundIndex(
        widget.client.getGameState().players, widget.id);

    timerKeys = [
      for (int i = 0; i < rotatedPlayers.length; i++) GlobalKey<FCTimerState>()
    ];

    _updateUi();

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        debugPrint("User has left the game screen");
      }
      if (widget.client.isModified && mounted) {
        _updateUi();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Player self = rotatedPlayers[0];
    GlobalKey<FCTimerState> selfTimer = timerKeys[0];

    return Scaffold(
        body: Column(
      children: [
        _buildPlayerRow(),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                        color: Color.fromRGBO(130, 195, 255, .5)),
                    child: FCTimer(
                      running: self.status == PlayerStatus.turn &&
                          gameStatus == GameStatus.inProgress,
                      initialTime: self.time,
                      style: FCButton.styleFrom(
                          textStyle: TextStyle(fontSize: 56),
                          backgroundColor:
                              FCColors.fromPlayerStatus[self.status],
                          disabledBackgroundColor:
                              FCColors.fromPlayerStatus[self.status]),
                      key: selfTimer,
                      enabled: self.status == PlayerStatus.first ||
                          self.status == PlayerStatus.turn,
                      onStop: (stopTime) {
                        widget.client.next(selfTimer.currentState!.getTime());
                      },
                      onTimeout: () => {widget.client.lost()},
                    )))),
        ButtonBar(alignment: MainAxisAlignment.center, children: [
          IconButton(
            //PAUSE/RESUME
            iconSize: 80,
            onPressed: gameStatus == GameStatus.starting ||
                    gameStatus == GameStatus.finished
                ? null
                : () {
                    widget.client.pause();
                  },
            icon: Icon(gameStatus == GameStatus.inProgress ||
                    gameStatus == GameStatus.finished
                ? Icons.pause_sharp
                : Icons.play_arrow_sharp),
          ),
          Visibility(
            //Must hide the reset button if we are not the host
            visible: widget.isHost,
            child: IconButton(
              //RESET BUTTON
              iconSize: 80,
              onPressed: gameStatus == GameStatus.starting
                  ? null
                  : () {
                      widget.client.reset();
                    },
              icon: const Icon(Icons.restore_sharp),
            ),
          ),
          IconButton(
              //RESIGNS
              iconSize: 80,
              onPressed: gameStatus == GameStatus.finished
                  ? null
                  : () {
                      widget.client.lost();
                      if (self.status == PlayerStatus.lost) {
                        setState(() {
                          _showDialog();
                        });
                      }
                    },
              icon: self.status == PlayerStatus.lost
                  ? const Icon(Icons.close)
                  : Icon(MdiIcons.skullOutline)),
        ]),
        const Padding(padding: EdgeInsets.only(bottom: 10))
      ],
    ));
  }

  //update ui for everything that can change
  void _updateUi() {
    gameState = widget.client.getGameState();
    setState(() {
      gameStatus = gameState.status;

      for (int i = 0; i < timerKeys.length; i++) {
        //set appropriate timer state
        GlobalKey<FCTimerState> timerKey = timerKeys[i];
        Player player = rotatedPlayers[i];

        if (timerKey.currentState != null) {
          timerKey.currentState!.setTime(player.time);
        }
      }
    });
  }

  //Build player row
  Row _buildPlayerRow() {
    List<Widget> bar = [];

    for (int i = 1; i < rotatedPlayers.length; i++) {
      bar.add(OtherPlayerTimer(
        timerState: timerKeys[i],
        playerInfo: rotatedPlayers[i],
        gameStatus: gameStatus,
      ));

      if (i != rotatedPlayers.length - 1) {
        bar.add(const Padding(padding: EdgeInsets.only(right: 20)));
      }
    }

    return Row(children: bar);
  }

  //Todo: understandand and fix warning that pops up whenever this is called
  void _showDialog() {
    String message = widget.isHost
        ? 'ARE YOU SURE YOU WANT TO END THE GAME FOR ALL PLAYERS?'
        : 'ARE YOU SURE YOU WANT TO QUIT THE GAME?';
    showDialog(
        context: context,
        builder: (BuildContext context) => FCAlertDialog(message: message));
  }

  List<T> _rotateArrayAroundIndex<T>(List<T> array, int index) {
    if (array.isEmpty || index < 0 || index >= array.length) {
      throw ArgumentError('Invalid index or empty array');
    }

    List<T> result = [];

    for (int i = 0; i < array.length; i++) {
      int currIndex =
          i + index < array.length ? i + index : i + index - array.length;
      result.add(array[currIndex]);
    }

    return result;
  }
}
