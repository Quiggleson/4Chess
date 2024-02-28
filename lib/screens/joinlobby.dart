import 'package:flutter/material.dart';
import 'package:fourchess/util/gamestate.dart';
import 'package:fourchess/screens/game.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'package:fourchess/widgets/fc_backbutton.dart';
import 'dart:async';
import '../backend/client.dart';
import '../util/player.dart';
import '../widgets/fc_numbereditem.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fourchess/widgets/fc_alertdialog.dart';
import 'package:fourchess/widgets/fc_button.dart';

class JoinLobby extends StatefulWidget {
  JoinLobby({super.key, required this.client, required this.roomCode});

  final Client client;
  final String roomCode;
  @override
  JoinLobbyState createState() => JoinLobbyState();
}

class JoinLobbyState extends State<JoinLobby> {
  @override
  void initState() {
    void toGoGame() {
      //At this point, client is guaranteed to have no listeners, as initializing this screen requires constructing a new client instance in joinSetup.
      if (mounted &&
          widget.client.getGameState().status == GameStatus.starting) {
        debugPrint('Im the front end and I know the game state is starting');
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => Game(
                  client: widget.client, id: widget.client.getPlayerIndex())),
        );
        widget.client.removeListener(toGoGame);
      }
    }

    void gameTerminated() {
      if (mounted &&
          widget.client.getGameState().status == GameStatus.terminated) {
        debugPrint('Im the front end and I know the game state is terminated');
        _showTerminatedDialog();
        widget.client.removeListener(gameTerminated);
      }
    }

    widget.client.addListener(toGoGame);
    widget.client.addListener(gameTerminated);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: FCAppBar(
          title: Text(
              "${AppLocalizations.of(context)!.joinGame}\n${AppLocalizations.of(context)!.code(widget.roomCode)}"),
          toolbarHeight: 140,
          leading: FCBackButton(onPressed: () => widget.client.leave()),
        ),
        body: Padding(
            padding: const EdgeInsets.all(30),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Center(
                  //I HAVE NO IDEA WHY THE CENTER IS NEEDED, IT DOESN'T WORK OTHERWISE
                  child: ListenableBuilder(
                      listenable: widget.client,
                      builder: (context, child) {
                        List<Player> playerList =
                            widget.client.getGameState().players;
                        return Text(
                            (4 - playerList.length == 0)
                                ? AppLocalizations.of(context)!.waitingForHost
                                : AppLocalizations.of(context)!
                                    .nPlayers(4 - playerList.length),
                            style: const TextStyle(fontSize: 24),
                            textAlign: TextAlign.center);
                      })),
              const Padding(padding: EdgeInsets.only(top: 20)),
              ListenableBuilder(
                  listenable: widget.client,
                  builder: (context, child) {
                    //if game is not starting, then the host has reordered the players
                    if (widget.client.getGameState().status !=
                        GameStatus.starting) {
                      return Expanded(
                          child: LayoutBuilder(builder: (context, constraints) {
                        //debugPrint('HEIGHT ${constraints.maxHeight.toString()}');
                        List<Player> playerList =
                            widget.client.getGameState().players;
                        return ListView(children: [
                          for (int i = 0; i < playerList.length; i++)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: FCNumberedItem(
                                  height: (constraints.maxHeight -
                                          (playerList.length) * 20) /
                                      4,
                                  content: playerList[i].name,
                                  number: i + 1),
                            )
                        ]);
                      }));
                    }

                    return const Text("");
                  })
            ])));
  }

  void _showTerminatedDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => FCAlertDialog(
                message: AppLocalizations.of(context)!.endedByHost,
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
