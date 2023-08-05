import 'package:flutter/material.dart';
import 'package:fourchess/screens/game.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'package:fourchess/widgets/fc_button.dart';
import 'package:fourchess/widgets/fc_numbereditem.dart';
import 'dart:async';

import '../client.dart';
import '../player.dart';

class HostLobby extends StatefulWidget {
  HostLobby({super.key, required this.roomCode, required this.client})
      : _playerList = client.getFakeGameState().players;

  final Client client;
  final String roomCode;
  List<Player> _playerList;
  @override
  HostLobbyState createState() => HostLobbyState();
}

// CREATE ORANGEG ANIMATION THINGY WHEN WE HAVE TIME
class HostLobbyState extends State<HostLobby> {
  @override
  Widget build(BuildContext context) {
    Timer.periodic(const Duration(milliseconds: 100), (Timer t) {
      //This code will run 10 times a second when the host menu starts
      if (widget.client.isModified) {
        setState(() {
          widget._playerList = widget.client.getGameState().players;
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
                  (4 - widget._playerList.length == 0)
                      ? ("START GAME WHEN READY")
                      : ("WAITING FOR ${4 - widget._playerList.length} PLAYERS"),
                  style: const TextStyle(fontSize: 28),
                  textAlign: TextAlign.center),
              const Padding(padding: EdgeInsets.only(top: 30)),
              Expanded(
                  child: ReorderableListView(
                children: [
                  for (int i = 0; i < widget._playerList.length; i++)
                    Padding(
                      key: Key("$i"),
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FCNumberedItem(
                          content: widget._playerList[i].name, number: i + 1),
                    )
                ],
                onReorder: (int oldIndex, int newIndex) {
                  //----- this chunk may not be necessary depending on how fast the async update happens
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    Player item = widget._playerList.removeAt(oldIndex);
                    widget._playerList.insert(newIndex, item);
                    //------

                    widget.client.reorder(widget._playerList);
                  });
                },
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
}
