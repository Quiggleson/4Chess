import 'package:flutter/material.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'dart:async';
import '../util/playerinfo.dart';

class JoinLobby extends StatefulWidget {
  //JoinLobby({super.key, required this.client});
  JoinLobby({super.key, required this.roomCode});

  //final Client client;
  final String roomCode;
  @override
  JoinLobbyState createState() => JoinLobbyState();
}

class JoinLobbyState extends State<JoinLobby> {
  List _playerList = <_TempPlayer>[];

  @override
  Widget build(BuildContext context) {
    Timer.periodic(const Duration(milliseconds: 100), (Timer t) {
      //This code will run 10 times a second when the host menu starts

      //if(widget.client.isModified)
      //_names = client.players (or something like that)

      //if game is ready to start, navigate to game screen
      /**
        * Navigator.of(context).push(
              MaterialPageRoute(
               //builder: (context) => Game(widget.client);
            ),
          )
       */
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
                  child: Text("WAITING FOR ${4 - _playerList.length} PLAYERS",
                      style: const TextStyle(fontSize: 28),
                      textAlign: TextAlign.center)),
            ])));
  }
}

//class and references to be replaced with regular player class
class _TempPlayer {
  const _TempPlayer(this.name, this.ip, this.status, this.remainingTime);

  final String name;
  final String ip;
  final GameStatus status;
  final double remainingTime;
}
