import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:fourchess/theme/fc_colors.dart';
import 'package:fourchess/widgets/fc_button.dart';
import 'package:fourchess/widgets/fc_timer.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../util/playerinfo.dart';
import '../widgets/fc_otherplayertimer.dart';

class Game extends StatefulWidget {
  @override
  GameState createState() => GameState();
}

class GameState extends State<Game> {
  final GlobalKey<FCTimerState> _timerState = GlobalKey();

  //TEMPORARY VALUE TO TEST RESET
  bool _isFirst = true;

  //Determined by host
  int id = 0;
  List<PlayerInfo> players = [
    PlayerInfo("Deven", PlayerStatus.first, 20),
    PlayerInfo("Aaron", PlayerStatus.notTurn, 180),
    PlayerInfo("Robert", PlayerStatus.notTurn, 180),
    PlayerInfo("Waldo", PlayerStatus.notTurn, 180)
  ];

  late List<PlayerInfo> _rotatedPlayers;

  GameStatus gameStatus = GameStatus.starting;

  @override
  Widget build(BuildContext context) {
    //players = Host.getData();
    _rotatedPlayers = _rotateArrayAroundIndex(players, id);
    PlayerInfo self = _rotatedPlayers[0];

    //set appropriate timer state
    if (_timerState.currentState != null) {
      if (self.status == PlayerStatus.turn &&
          gameStatus == GameStatus.inProgress) {
        _timerState.currentState!.start();
      } else {
        _timerState.currentState!.stop();

        if (gameStatus == GameStatus.starting) {
          //RESETS THE TIME
          _timerState.currentState!.setTime(self.time);
        }
      }
    }

    //

    //print(_rotatedPlayers);
    //print(gameStatus);

    return Scaffold(
        body: Column(
      children: [
        Row(children: [
          OtherPlayerTimer(
            playerInfo: _rotatedPlayers[1],
            gameStatus: gameStatus,
          ),
          const Padding(padding: EdgeInsets.only(right: 20)),
          OtherPlayerTimer(
              playerInfo: _rotatedPlayers[2], gameStatus: gameStatus),
          const Padding(padding: EdgeInsets.only(right: 20)),
          OtherPlayerTimer(
              playerInfo: _rotatedPlayers[3], gameStatus: gameStatus)
        ]),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                        color: Color.fromRGBO(130, 195, 255, .5)),
                    child: FCTimer(
                      initialTime: self.time,
                      style: FCButton.styleFrom(
                          backgroundColor:
                              FCColors.fromPlayerStatus[self.status],
                          disabledBackgroundColor:
                              FCColors.fromPlayerStatus[self.status]),
                      key: _timerState,
                      enabled: self.status == PlayerStatus.first ||
                          self.status == PlayerStatus.turn,
                      onStart: (startTime) => setState(_onStart),
                      onStop: (stopTime) {
                        //Ensures that the turn does not called twice, will likely not be necsesary in the end
                        if (self.status == PlayerStatus.turn) setState(_onStop);
                      },
                      onTick: (currentTime) {
                        //LISTEN FOR REQUESTS FROM CLIENTS (PROBABLY)
                      },
                      onTimeout: () => setState(() => _onTimeout(id)),
                    )))),
        ButtonBar(alignment: MainAxisAlignment.center, children: [
          TextButton(
              onPressed: () => setState(_nextPlayersTurn),
              child: const Text("NEXT TURN")),
          TextButton(
              onPressed: () => setState(() => _won(0)),
              child: const Text("WON")),
          IconButton(
            //PAUSE/RESUME
            iconSize: 80,
            onPressed: gameStatus == GameStatus.starting ||
                    gameStatus == GameStatus.finished
                ? null
                : () {
                    //Host.onPause()
                    setState(() {
                      gameStatus = gameStatus == GameStatus.inProgress
                          ? GameStatus.paused
                          : GameStatus.inProgress;

                      if (self.status == PlayerStatus.turn) {
                        _timerState.currentState!.toggle();
                      }
                    });
                  },
            icon: Icon(gameStatus == GameStatus.inProgress ||
                    gameStatus == GameStatus.finished
                ? Icons.pause_sharp
                : Icons.play_arrow_sharp),
          ),
          IconButton(
            //RESET BUTTON
            iconSize: 80,
            onPressed: gameStatus == GameStatus.starting
                ? null
                : () {
                    //Host.onReset()
                    setState(() => _reset(id, 180));
                  },
            icon: const Icon(Icons.restore_sharp),
          ),
          IconButton(
              //RESIGNS
              iconSize: 80,
              onPressed: gameStatus == GameStatus.finished
                  ? null
                  : () => setState(() {
                        //Host.onResigns()

                        //IF RESIGNS RESULTS IN A WIN, THEN GAME IS FINISHED
                        //OTHERWISE, WE CONTINUE
                        if (self.status != PlayerStatus.lost) {
                          _onLost(id);
                        } else {}
                      }),
              icon: self.status == PlayerStatus.lost
                  ? const Icon(Icons.close)
                  : Icon(MdiIcons.skullOutline)),
        ])
      ],
    ));
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

  void _reset(int firstId, double initialTime) {
    gameStatus = GameStatus.starting;

    for (int i = 0; i < _rotatedPlayers.length; i++) {
      PlayerInfo curr = _rotatedPlayers[i];
      curr.time = initialTime;
      curr.status = i == firstId ? PlayerStatus.first : PlayerStatus.notTurn;
    }
  }

  void _onStart() {
    //Host.onStart()

    //FOR TESTING PURPOSES
    PlayerInfo self = _rotatedPlayers[id];
    if (self.status == PlayerStatus.first) {
      gameStatus = GameStatus.inProgress;
      self.status = PlayerStatus.turn;
    }
  }

  void _onStop() {
    //CALL FUNCTION Host.onStop()
    _nextPlayersTurn();
  }

  void _onTimeout(int id) {
    _onLost(id);
  }

  void _onLost(int id) {
    //Host.onLost()

    //FOR TESTING
    PlayerInfo self = _rotatedPlayers[id];
    self.status = PlayerStatus.lost;
    _nextPlayersTurn();
  }

  //TEST METHODS - TO BE REMOVED
  void _nextPlayersTurn() {
    if (gameStatus == GameStatus.starting) {
      gameStatus = GameStatus.inProgress;
    }

    int turnId = _rotatedPlayers
        .indexWhere((player) => player.status == PlayerStatus.turn);

    int nextId = (turnId + 1) % _rotatedPlayers.length;

    _rotatedPlayers[turnId].status = PlayerStatus.notTurn;
    _rotatedPlayers[nextId].status = PlayerStatus.turn;
  }

  //LOGIC WILL BE HANDLED BY SERVER
  void _won(int id) {
    gameStatus = GameStatus.finished;

    for (int i = 0; i < _rotatedPlayers.length; i++) {
      if (i == id) {
        _rotatedPlayers[i].status = PlayerStatus.won;
      } else {
        _rotatedPlayers[i].status = PlayerStatus.lost;
      }
    }
  }
}
