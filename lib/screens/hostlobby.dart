import 'package:flutter/material.dart';
import 'package:fourchess/screens/game.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'package:fourchess/widgets/fc_button.dart';
import 'package:fourchess/widgets/fc_numbereditem.dart';
import 'dart:async';

import '../backend/client.dart';
import '../util/player.dart';

class HostLobby extends StatefulWidget {
  HostLobby({super.key, required this.roomCode, required this.client});

  final Client client;
  final String roomCode;

  @override
  HostLobbyState createState() => HostLobbyState();
}

// CREATE ORANGEG ANIMATION THINGY WHEN WE HAVE TIME
class HostLobbyState extends State<HostLobby> {
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
      if (widget.client.isModified) {
        setState(() {
          playerList = widget.client.getGameState().players;
        });
      }
    });

    return Scaffold(
        appBar: FCAppBar(
          title: Text("HOST GAME\nCODE: ${widget.roomCode}"),
          toolbarHeight: 180,
        ),
        body: Padding(
            padding: const EdgeInsets.all(40),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Text(
                  (4 - playerList.length == 0)
                      ? ("START GAME WHEN READY")
                      : ("WAITING FOR ${4 - playerList.length} PLAYERS"),
                  style: const TextStyle(fontSize: 28),
                  textAlign: TextAlign.center),
              const Padding(padding: EdgeInsets.only(top: 30)),
              Expanded(
                  child: ReorderableListView(
                children: [
                  for (int i = 0; i < playerList.length; i++)
                    Padding(
                      key: Key("$i"),
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FCNumberedItem(
                          content: playerList[i].name, number: i + 1),
                    )
                ],
                onReorder: (int oldIndex, int newIndex) =>
                    _onReorder(oldIndex, newIndex),
              )),
              const Padding(padding: EdgeInsets.only(top: 40)),
              const Text("DRAG AND DROP NAMES TO CHANGE PLAYER ORDER",
                  style: TextStyle(fontSize: 28), textAlign: TextAlign.center),
              const Padding(padding: EdgeInsets.only(top: 40)),
              FCButton(
                  onPressed: () {
                    //Should we return future from start for confirmation/error handling?
                    widget.client.start();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        //if (status.isGood)
                        builder: (context) =>
                            Game(client: widget.client, isHost: true),
                      ),
                    );
                  },
                  child: const Text("START"))
            ])));
  }

  _onReorder(int oldIndex, int newIndex) {
    //----- this chunk may not be necessary depending on how fast the async update happens
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      Player item = playerList.removeAt(oldIndex);
      playerList.insert(newIndex, item);
      //------

      widget.client.reorder(playerList);
    });
  }
}
