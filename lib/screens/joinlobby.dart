import 'package:flutter/material.dart';
import 'package:fourchess/widgets/fc_appbar.dart';

class JoinLobby extends StatefulWidget {
  JoinLobby({super.key});

  @override
  JoinLobbyState createState() => JoinLobbyState();
}

class JoinLobbyState extends State<JoinLobby> {
  String _roomcode = "ZOLF";
  int _numPlayersJoined = 2;

  //TIMER TO LISTEN FOR UPDATED LIST

  //TODO: ITERATELIST DYNACMICALLY

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: FCAppBar(
          title: Text("JOIN GAME\nCODE: $_roomcode"),
          toolbarHeight: 180,
        ),
        body: Padding(
            padding: const EdgeInsets.all(40),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Center(
                  //I HAVE NO IDEA WHY THE CENTER IS NEEDED, IT DOESN'T WORK OTHERWISE
                  child: Text("WAITING FOR ${4 - _numPlayersJoined} PLAYERS",
                      style: const TextStyle(fontSize: 28),
                      textAlign: TextAlign.center)),
            ])));
  }
}
