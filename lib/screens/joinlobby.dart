import 'package:flutter/material.dart';
import 'package:fourchess/util/gamestate.dart';
import 'package:fourchess/screens/game.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'dart:async';
import '../backend/client.dart';
import '../util/player.dart';
import '../widgets/fc_numbereditem.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class JoinLobby extends StatefulWidget {
  JoinLobby({super.key, required this.client, required this.gameCode});

  final Client client;
  final String gameCode;
  @override
  JoinLobbyState createState() => JoinLobbyState();
}

class JoinLobbyState extends State<JoinLobby> {
  late List<Player> playerList;

  @override
  void initState() {
    playerList = widget.client.getGameState().players;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Timer.periodic(const Duration(milliseconds: 100), (Timer t) {
      //This code will run 10 times a second when the host menu starts
      if (widget.client.isDirty()) {
        //We move to game screen when we game is starting
        if (widget.client.getGameState().status == GameStatus.starting) {
          debugPrint('Im the front end and I know the game state is starting');
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => Game(
                    client: widget.client, id: widget.client.getPlayerIndex())),
          );
        } else {
          //if game is not starting, then the host has reordered the players
          setState(() {
            playerList = widget.client.getGameState().players;
          });
        }
      }
    });

    return Scaffold(
        appBar: FCAppBar(
          title: Text(
              "${AppLocalizations.of(context)!.joinGame}\n${AppLocalizations.of(context)!.code(widget.gameCode)}"),
          toolbarHeight: 140,
        ),
        body: Padding(
            padding: const EdgeInsets.all(30),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Center(
                  //I HAVE NO IDEA WHY THE CENTER IS NEEDED, IT DOESN'T WORK OTHERWISE
                  child: Text(
                      (4 - playerList.length == 0)
                          ? AppLocalizations.of(context)!.waitingForHost
                          : AppLocalizations.of(context)!
                              .nPlayers(4 - playerList.length),
                      style: const TextStyle(fontSize: 24),
                      textAlign: TextAlign.center)),
              const Padding(padding: EdgeInsets.only(top: 20)),
              Expanded(child: LayoutBuilder(builder: (context, constraints) {
                //debugPrint('HEIGHT ${constraints.maxHeight.toString()}');
                return ListView(children: [
                  for (int i = 0; i < playerList.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FCNumberedItem(
                          height: (constraints.maxHeight -
                                  (playerList.length) * 20) /
                              4,
                          content: playerList[i].name,
                          number: i + 1),
                    )
                ]);
              }))
            ])));
  }
}
