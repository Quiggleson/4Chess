import 'package:flutter/material.dart';
import 'package:fourchess/theme/fc_colors.dart';
import 'package:fourchess/widgets/fc_button.dart';
import 'package:fourchess/widgets/fc_timer.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:async';
import '../util/playerinfo.dart';
import '../widgets/fc_otherplayertimer.dart';

class Game extends StatefulWidget {
  //Game(required this.client, this.isHost = false);

  //Client client
  //bool isHost
  @override
  GameState createState() => GameState();
}

class GameState extends State<Game> {
  //update when request is heard
  List<PlayerInfo> players = [
    PlayerInfo("Deven", PlayerStatus.lost, 180),
    PlayerInfo("Aaron", PlayerStatus.notTurn, 180),
    PlayerInfo("Robert", PlayerStatus.notTurn, 180),
    PlayerInfo("Waldo", PlayerStatus.notTurn, 180)
  ];

  //id determined by users IP cross referenced with list sent from server??
  int id = 0;

  //update when request is heard
  GameStatus gameStatus = GameStatus.starting;

  late List<PlayerInfo> _rotatedPlayers;

  final GlobalKey<FCTimerState> _timerState = GlobalKey();

  final GlobalKey<OtherPlayerTimerState> _player1 = GlobalKey();
  final GlobalKey<OtherPlayerTimerState> _player2 = GlobalKey();
  final GlobalKey<OtherPlayerTimerState> _player3 = GlobalKey();

  @override
  Widget build(BuildContext context) {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      //if(client.isModified){
      //gameState = client.getGameState()

      //setState(()=>{
      //players = gameState.players
      //set other players times
      //etc.
      //});
      //}
    });

    //Set this player to be the main screen
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

    return Scaffold(
        body: Column(
      children: [
        Row(children: [
          OtherPlayerTimer(
            key: _player1,
            playerInfo: _rotatedPlayers[1],
            gameStatus: gameStatus,
          ),
          const Padding(padding: EdgeInsets.only(right: 20)),
          OtherPlayerTimer(
              key: _player2,
              playerInfo: _rotatedPlayers[2],
              gameStatus: gameStatus),
          const Padding(padding: EdgeInsets.only(right: 20)),
          OtherPlayerTimer(
              key: _player3,
              playerInfo: _rotatedPlayers[3],
              gameStatus: gameStatus)
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
                      onStop: (stopTime) {
                        //Client.next(myTime)
                      },
                      onTimeout: () => {
                        //Client.lost()
                      },
                    )))),
        ButtonBar(alignment: MainAxisAlignment.center, children: [
          IconButton(
            //PAUSE/RESUME
            iconSize: 80,
            onPressed: gameStatus == GameStatus.starting ||
                    gameStatus == GameStatus.finished
                ? null
                : () {
                    //Client.onPause()
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
                    //Client.gameReset()
                  },
            icon: const Icon(Icons.restore_sharp),
          ),
          IconButton(
              //RESIGNS
              iconSize: 80,
              onPressed: gameStatus == GameStatus.finished
                  ? null
                  : () => {
                        //Client.onLost
                        if (self.status == PlayerStatus.lost)
                          {
                            setState(() {
                              _showDialog();
                            })
                          }
                      },
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

  //ALERT DIALOGS

  //TODO: FIX ERROR EVERYTIME THIS GETS CALLED LMAO
  void _showDialog() {
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
          content: const Text(
              'ARE YOU SURE YOU WANT TO END THE GAME FOR ALL PLAYERS?'),
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
}
