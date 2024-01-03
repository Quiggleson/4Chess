import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fourchess/theme/fc_colors.dart';
import 'package:fourchess/widgets/debugonly.dart';
import 'package:fourchess/widgets/fc_alartdialog.dart';
import 'package:fourchess/widgets/fc_button.dart';
import 'package:fourchess/widgets/fc_timer.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:async';
import '../backend/client.dart';
import '../util/gamestate.dart';
import '../util/player.dart';
import '../widgets/fc_otherplayertimer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  late List<GlobalKey<FCTimerState>> timerKeys;
  late GlobalKey<FCTimerState> selfTimer;
  late int numPlayers;
  late Player self;

  @override
  void initState() {
    super.initState();
    numPlayers = widget.client.getGameState().players.length;
    self = widget.client.getGameState().players[_getPlayerOffset(0)];
    timerKeys = [
      for (int i = 0; i < numPlayers; i++) GlobalKey<FCTimerState>()
    ];
    selfTimer = timerKeys[0];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: widget.client,
        builder: (_, __) {
          GameState state = widget.client.getGameState();
          GameStatus gameStatus = state.status;
          List<Player> players = state.players;

          for (int i = 0; i < numPlayers; i++) {
            Player player = players[i];
            if (player.status == PlayerStatus.turn) {
              timerKeys[i].currentState!.start();
            } else {
              timerKeys[i].currentState!.stop();
            }
          }

          return Scaffold(
              body: Column(
            children: [
              _buildPlayerRow(gameStatus),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                              color: Color.fromRGBO(130, 195, 255, .5)),
                          child: FCTimer(
                            initialTime: self.time,
                            style: FCButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 56),
                                backgroundColor:
                                    FCColors.fromPlayerStatus[self.status],
                                disabledBackgroundColor:
                                    FCColors.fromPlayerStatus[self.status]),
                            key: selfTimer,
                            enabled: self.status == PlayerStatus.first ||
                                self.status == PlayerStatus.turn,
                            onStop: (stopTime) {
                              widget.client
                                  .next(selfTimer.currentState!.getTime());
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
              DebugOnly(text: "show popup", onPress: _forceShowDialog),
              const Padding(padding: EdgeInsets.only(bottom: 10))
            ],
          ));
        });
  }

  //Build player row
  Row _buildPlayerRow(GameStatus gameStatus) {
    List<Widget> bar = [];

    for (int i = 1; i < numPlayers; i++) {
      Player player = widget.client.getGameState().players[_getPlayerOffset(i)];
      bar.add(OtherPlayerTimer(
        timerState: timerKeys[_getPlayerOffset(i)],
        playerInfo: player,
        gameStatus: gameStatus,
      ));

      if (i != numPlayers - 1) {
        bar.add(const Padding(padding: EdgeInsets.only(right: 20)));
      }
    }

    return Row(children: bar);
  }

  //Todo: understandand and fix warning that pops up whenever this is called
  void _showDialog() {
    String message = widget.isHost
        ? AppLocalizations.of(context)!.endGameForAll
        : AppLocalizations.of(context)!.quitGame;
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            FCAlertDialog(message: message, actions: <Widget>[
              FCButton(
                onPressed: () =>
                    Navigator.popUntil(context, ModalRoute.withName('/')),
                child: Text(AppLocalizations.of(context)!.yes),
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              FCButton(
                onPressed: () => Navigator.pop(context, 'No'),
                child: Text(AppLocalizations.of(context)!.no),
              ),
            ]));
  }

  int _getPlayerOffset(offset) {
    return (offset % numPlayers) as int;
  }

  _forceShowDialog(BuildContext context) {
    _showDialog();
  }
}
