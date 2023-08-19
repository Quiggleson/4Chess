import 'package:flutter/material.dart';
import 'package:fourchess/util/gamestate.dart';
import 'package:fourchess/screens/game.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'dart:async';
import '../backend/client.dart';
import '../util/player.dart';
import '../widgets/fc_numbereditem.dart';

class JoinLobby extends StatefulWidget {
  JoinLobby({super.key, required this.client, required this.roomCode});

  final Client client;
  final String roomCode;
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
                builder: (context) => Game(client: widget.client, id: 0)),
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
          title: Text("JOIN GAME\nCODE: ${widget.roomCode}"),
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
                          ? ("WAITING FOR HOST TO START GAME")
                          : ("WAITING FOR ${4 - playerList.length} PLAYERS"),
                      style: const TextStyle(fontSize: 24),
                      textAlign: TextAlign.center)),
              const Padding(padding: EdgeInsets.only(top: 30)),
              Expanded(
                  child: ListView(children: [
                for (int i = 0; i < playerList.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: FCNumberedItem(
                        content: playerList[i].name, number: i + 1),
                  )
              ]))
            ])));
  }
}
