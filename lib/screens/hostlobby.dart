import 'package:flutter/material.dart';
import 'package:fourchess/screens/game.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'package:fourchess/widgets/fc_button.dart';
import 'package:fourchess/widgets/fc_loadinganimation.dart';
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

  bool loading = false;

  @override
  void initState() {
    playerList = widget.client.getFakeGameState().players;
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
          toolbarHeight: 140,
        ),
        body: Padding(
            padding: const EdgeInsets.all(30),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Text(
                  (4 - playerList.length == 0)
                      ? ("START GAME WHEN READY")
                      : ("WAITING FOR ${4 - playerList.length} PLAYERS"),
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center),
              const Padding(padding: EdgeInsets.only(top: 20)),
              Expanded(
                  child: ReorderableListView(
                physics: BouncingScrollPhysics(),
                proxyDecorator: (child, index, animation) => child,
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
              const Padding(padding: EdgeInsets.only(top: 20)),
              const Text("DRAG AND DROP NAMES TO CHANGE PLAYER ORDER",
                  style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
              const Padding(padding: EdgeInsets.only(top: 20)),
              loading
                  ? const FCLoadingAnimation()
                  : FCButton(
                      onPressed: playerList.length < 4
                          ? null
                          : () => _onStart(context),
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

  _onStart(BuildContext context) {
    Client client = widget.client;

    client.start();

    setState(() => loading = true);

    double elapsedTime = 0;

    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      //checks twice a second to see if have successfully joined the game
      elapsedTime += .5;

      //Mounted checks if the widget is still in the build tree i.e make sure we're still on this screen before we do
      //any funny stuff

      if (!mounted) {
        timer.cancel();
        debugPrint("User has left the join setup screen");
      }

      if (client.isModified && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            //if (status.isGood)
            builder: (context) =>
                Game(client: widget.client, id: 0, isHost: true),
          ),
        );
        timer.cancel();
        client.isModified = false;
      }

      debugPrint("Time elapsed since attempting to start game: $elapsedTime");

      if (elapsedTime > 10 && mounted) {
        //We have taken more than 10 seconds to connect, probably a network
        //issue
        debugPrint("Failed to start game");
        setState(() => loading = false);
        timer.cancel();
      }
    });

    //FORCING THE JOIN OF THE NEXT PAGE - THIS IS PURELY FOR TESTING PURPOSES
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     //if (status.isGood)
    //     builder: (context) => Game(client: widget.client, id: 0, isHost: true),
    //   ),
    // );
  }
}
