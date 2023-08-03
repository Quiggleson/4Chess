import 'package:flutter/material.dart';
import 'package:fourchess/screens/game.dart';
import 'package:fourchess/util/playerinfo.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'package:fourchess/widgets/fc_button.dart';
import 'package:fourchess/widgets/fc_numbereditem.dart';
import 'dart:async';

class HostLobby extends StatefulWidget {
  //HostLobby({super.key, required this.roomCode, required this.client});
  const HostLobby({super.key, required this.roomCode});

  //Client client;
  final String roomCode;
  @override
  HostLobbyState createState() => HostLobbyState();
}

// CREATE ORANGEG ANIMATION THINGY WHEN WE HAVE TIME
class HostLobbyState extends State<HostLobby> {
  List _playerList = <_TempPlayer>[];

  @override
  Widget build(BuildContext context) {
    Timer.periodic(const Duration(milliseconds: 100), (Timer t) {
      //This code will run 10 times a second when the host menu starts

      //if(widget.client.isModified)
      //_names = client.players (or something like that)
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
              Text("WAITING FOR ${4 - _playerList.length} PLAYERS",
                  style: const TextStyle(fontSize: 28),
                  textAlign: TextAlign.center),
              const Padding(padding: EdgeInsets.only(top: 30)),
              Expanded(
                  child: ReorderableListView(
                children: <Widget>[
                  for (int i = 0; i < _playerList.length; i++)
                    Padding(
                      key: Key("$i"),
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FCNumberedItem(
                          content: _playerList[i], number: i + 1),
                    )
                ],
                onReorder: (int oldIndex, int newIndex) {
                  //----- this chunk may not be necessary depending on how fast the async update happens
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    String item = _playerList.removeAt(oldIndex);
                    _playerList.insert(newIndex, item);
                    //------

                    //widget.client.reorder(_playerList)
                  });
                },
              )),
              const Padding(padding: EdgeInsets.only(top: 40)),
              const Text("DRAG AND DROP NAMES TO CHANGE PLAYER ORDER",
                  style: TextStyle(fontSize: 28), textAlign: TextAlign.center),
              const Padding(padding: EdgeInsets.only(top: 40)),
              FCButton(
                  onPressed: () => {
                        //Future<> status = widget.client.start() Should we return future here for confirmation?
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            //if (status.isGood)
                            //builder: (context) => Game(widget.client, true),
                            builder: (context) => Game(),
                          ),
                        )
                      },
                  child: const Text("START"))
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
