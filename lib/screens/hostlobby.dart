import 'package:flutter/material.dart';
import 'package:fourchess/screens/game.dart';
import 'package:fourchess/util/gamestate.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'package:fourchess/widgets/fc_button.dart';
import 'package:fourchess/widgets/fc_loadinganimation.dart';
import 'package:fourchess/widgets/fc_numbereditem.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../backend/client.dart';
import '../util/player.dart';

class HostLobby extends StatefulWidget {
  HostLobby({super.key, required this.gameCode, required this.client});

  final Client client;
  final String gameCode;

  @override
  HostLobbyState createState() => HostLobbyState();
}

// CREATE ORANGEG ANIMATION THINGY WHEN WE HAVE TIME
class HostLobbyState extends State<HostLobby> {
  late List<Player> playerList;

  bool starting = false;
  double elapsedTime = 0;

  @override
  void initState() {
    playerList = widget.client.getGameState().players;
    Timer.periodic(const Duration(milliseconds: 500), (Timer timer) {
      //This code will run 10 times a second when the host menu starts
      if (widget.client.isDirty()) {
        setState(() {
          if (widget.client.gameState.status == GameStatus.setup) {
            playerList = widget.client.getGameState().players;
          }
          if (starting) {
            elapsedTime += .5;

            if (mounted &&
                widget.client.gameState.status == GameStatus.starting) {
              debugPrint('I am the front end and I heard client is dirty');
              Navigator.of(context).push(
                MaterialPageRoute(
                  //if (status.isGood)
                  builder: (context) => Game(
                      client: widget.client,
                      id: widget.client.getPlayerIndex(),
                      isHost: true),
                ),
              );
              timer.cancel();
            }

            debugPrint(
                "Time elapsed since attempting to start game: $elapsedTime");

            if (elapsedTime > 10 && mounted) {
              //We have taken more than 10 seconds to connect, probably a network
              //issue
              debugPrint("Failed to start game");
              starting = false;
              elapsedTime = 0;
            }
          }
          if (!mounted) {
            debugPrint("User has left the host lobby screen");
            timer.cancel();
          }
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: FCAppBar(
          title: Text(AppLocalizations.of(context)!.code(widget.gameCode)),
          toolbarHeight: 140,
        ),
        body: Padding(
            padding: const EdgeInsets.all(30),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Text(
                  (4 - playerList.length == 0)
                      ? AppLocalizations.of(context)!.startGame
                      : AppLocalizations.of(context)!
                          .nPlayers(4 - playerList.length),
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center),
              const Padding(padding: EdgeInsets.only(top: 20)),
              Expanded(child: LayoutBuilder(builder: (context, constraints) {
                //debugPrint('HEIGHT ${constraints.maxHeight.toString()}');
                return ReorderableListView(
                  buildDefaultDragHandles: false,
                  physics: const BouncingScrollPhysics(),
                  proxyDecorator: (child, index, animation) => child,
                  children: [
                    for (int i = 0; i < playerList.length; i++)
                      Padding(
                        key: Key("$i"),
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: FCNumberedItem(
                            leading: ReorderableDragStartListener(
                              index: i,
                              child: const Icon(Icons.drag_handle),
                            ),
                            height: (constraints.maxHeight -
                                    (playerList.length) * 20) /
                                4,
                            content: playerList[i].name,
                            number: i + 1),
                      )
                  ],
                  onReorder: (int oldIndex, int newIndex) =>
                      _onReorder(oldIndex, newIndex),
                );
              })),
              const Padding(padding: EdgeInsets.only(top: 20)),
              Text(AppLocalizations.of(context)!.dragDrop,
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center),
              const Padding(padding: EdgeInsets.only(top: 20)),
              starting
                  ? const FCLoadingAnimation()
                  : FCButton(
                      onPressed:
                          playerList.isEmpty ? null : () => _onStart(context),
                      child: Text(AppLocalizations.of(context)!.start))
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
    widget.client.start();
    setState(() => starting = true);

    //FORCING THE JOIN OF THE NEXT PAGE - THIS IS PURELY FOR TESTING PURPOSES
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     //if (status.isGood)
    //     builder: (context) => Game(client: widget.client, id: 0, isHost: true),
    //   ),
    // );
  }
}
