import 'package:flutter/material.dart';
import 'package:fourchess/theme/fc_colors.dart';
import 'package:fourchess/widgets/fc_button.dart';
import 'package:fourchess/widgets/fc_timer.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:async';
import '../client.dart';
import '../gamestate.dart';
import '../player.dart';
import '../widgets/fc_otherplayertimer.dart';

class Game extends StatefulWidget {
  Game({super.key, required this.client, this.isHost = false});

  final Client client;
  final bool isHost;

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  late int id;
  late GameState gameState;
  late GameStatus gameStatus;
  late List<Player> rotatedPlayers;
  late List<GlobalKey<FCTimerState>> timerKeys;

  @override
  void initState() {
    //Initialize Id somehow?? setting 0 as default
    id = 0;

    rotatedPlayers =
        _rotateArrayAroundIndex(widget.client.getFakeGameState().players, id);
    timerKeys = [
      for (int i = 0; i < rotatedPlayers.length; i++) GlobalKey<FCTimerState>()
    ];

    _updateUi();

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (widget.client.isModified) {
        _updateUi();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Player self = rotatedPlayers[0];
    GlobalKey<FCTimerState> selfTimer = timerKeys[0];

    return Scaffold(
        body: Column(
      children: [
        _buildPlayerRow(timerKeys),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                        color: Color.fromRGBO(130, 195, 255, .5)),
                    child: FCTimer(
                      running: self.status == PlayerStatus.turn &&
                          gameStatus == GameStatus.inProgress,
                      initialTime: self.time,
                      style: FCButton.styleFrom(
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
                    setState(() {
                      gameStatus == GameStatus.inProgress
                          ? GameStatus.paused
                          : GameStatus.inProgress;
                    });
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
        ])
      ],
    ));
  }

  //update ui for everything that can change
  void _updateUi() {
    gameState = widget.client.getFakeGameState();
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
  Row _buildPlayerRow(List<GlobalKey<FCTimerState>> timerKeys) {
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

  //ALERT DIALOGS

  //TODO: FIX ERROR EVERYTIME THIS GETS CALLED LMAO
  void _showDialog() {
    String message = widget.isHost
        ? 'ARE YOU SURE YOU WANT TO END THE GAME FOR ALL PLAYERS?'
        : 'ARE YOU SURE YOU WANT TO QUIT THE GAME?';
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
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
          actions: <Widget>[
            FCButton(
              style: FCButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 28),
                  minimumSize: const Size.fromHeight(55)),
              onPressed: () =>
                  Navigator.popUntil(context, ModalRoute.withName('/')),
              child: const Text('Yes'),
            ),
            const Padding(padding: EdgeInsets.only(top: 15)),
            FCButton(
              style: FCButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 28),
                  minimumSize: const Size.fromHeight(55)),
              onPressed: () => Navigator.pop(context, 'No'),
              child: const Text('No'),
            ),
          ]),
    );
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
