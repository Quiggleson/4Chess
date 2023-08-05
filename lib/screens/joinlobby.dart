import 'package:flutter/material.dart';
import 'package:fourchess/gamestate.dart';
import 'package:fourchess/screens/game.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'dart:async';
import '../client.dart';
import '../player.dart';
import '../widgets/fc_numbereditem.dart';

class JoinLobby extends StatefulWidget {
  JoinLobby({super.key, required this.client, required this.roomCode})
      : _playerList = client.getFakeGameState().players;

  final Client client;
  final String roomCode;
  List<Player> _playerList;
  @override
  JoinLobbyState createState() => JoinLobbyState();
}

class JoinLobbyState extends State<JoinLobby> {
  @override
  Widget build(BuildContext context) {
    Timer.periodic(const Duration(milliseconds: 100), (Timer t) {
      //This code will run 10 times a second when the host menu starts
      if (widget.client.isModified) {
        //if game is ready to start, navigate to game screen.

        //Replace this with the condition of the game
        if (widget.client.getGameState().status == false) {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => Game(client: widget.client)),
          );
        } else {
          setState(() {
            widget._playerList = widget.client
                .getFakeGameState()
                .players; //uncomment when gameState/isModified works properly
          });
        }
      }
    });

    return Scaffold(
        appBar: FCAppBar(
          title: Text("JOIN GAME\nCODE: ${widget.roomCode}"),
          toolbarHeight: 180,
        ),
        body: Padding(
            padding: const EdgeInsets.all(40),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Center(
                  //I HAVE NO IDEA WHY THE CENTER IS NEEDED, IT DOESN'T WORK OTHERWISE
                  child: Text(
                      (4 - widget._playerList.length == 0)
                          ? ("WAITING FOR HOST TO START GAME")
                          : ("WAITING FOR ${4 - widget._playerList.length} PLAYERS"),
                      style: const TextStyle(fontSize: 28),
                      textAlign: TextAlign.center)),
              const Padding(padding: EdgeInsets.only(top: 30)),
              Expanded(
                  child: ListView(children: [
                for (int i = 0; i < widget._playerList.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: FCNumberedItem(
                        content: widget._playerList[i].name, number: i + 1),
                  )
              ]))
            ])));
  }
}
