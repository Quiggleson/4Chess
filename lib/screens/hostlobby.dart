import 'package:flutter/material.dart';
import 'package:fourchess/screens/game.dart';
import 'package:fourchess/util/gamestate.dart';
import 'package:fourchess/widgets/debugonly.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'package:fourchess/widgets/fc_backbutton.dart';
import 'package:fourchess/widgets/fc_button.dart';
import 'package:fourchess/widgets/fc_loadinganimation.dart';
import 'package:fourchess/widgets/fc_numbereditem.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  bool starting = false; //Triggers the loading animation

  @override
  void initState() {
    void goToGame() {
      if (mounted && widget.client.gameState.status == GameStatus.starting) {
        Navigator.of(context).push(
          MaterialPageRoute(
            //if (status.isGood)
            builder: (context) => Game(
                client: widget.client,
                id: widget.client.getPlayerIndex(),
                isHost: true),
          ),
        );
        widget.client.removeListener(goToGame);
      }
    }

    widget.client.addListener(goToGame);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: FCAppBar(
            title: Text(AppLocalizations.of(context)!.code(widget.roomCode)),
            toolbarHeight: 140,
            leading: FCBackButton(onPressed: () => widget.client.endGame())),
        body: Padding(
            padding: const EdgeInsets.all(30),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              ListenableBuilder(
                  listenable: widget.client,
                  builder: (_, __) {
                    List<Player> playerList =
                        widget.client.getGameState().players;
                    return Text(
                        (4 - playerList.length == 0)
                            ? AppLocalizations.of(context)!.startGame
                            : AppLocalizations.of(context)!
                                .nPlayers(4 - playerList.length),
                        style: const TextStyle(fontSize: 24),
                        textAlign: TextAlign.center);
                  }),
              const Padding(padding: EdgeInsets.only(top: 20)),
              Expanded(child: LayoutBuilder(builder: (context, constraints) {
                //debugPrint('HEIGHT ${constraints.maxHeight.toString()}');
                return ListenableBuilder(
                    listenable: widget.client,
                    builder: (_, __) {
                      if (widget.client.gameState.status == GameStatus.setup) {
                        List<Player> playerList =
                            widget.client.getGameState().players;
                        return ReorderableListView(
                          buildDefaultDragHandles: false,
                          physics: const BouncingScrollPhysics(),
                          proxyDecorator: (child, _, __) => child,
                          children: [
                            for (int i = 0; i < playerList.length; i++)
                              Padding(
                                key: Key("$i"),
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
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
                      } else {
                        return const SizedBox.shrink(); //Empty widget
                      }
                    });
              })),
              const Padding(padding: EdgeInsets.only(top: 20)),
              Text(AppLocalizations.of(context)!.dragDrop,
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center),
              const Padding(padding: EdgeInsets.only(top: 20)),
              DebugOnly(text: "force on start", onPress: _forceOnStart),
              starting
                  ? const FCLoadingAnimation()
                  : FCButton(
                      onPressed: widget.client.getGameState().players.isEmpty
                          ? null
                          : () => _onStart(),
                      child: Text(AppLocalizations.of(context)!.start))
            ])));
  }

  _onReorder(int oldIndex, int newIndex) {
    List<Player> playerList = widget.client.getGameState().players;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    Player item = playerList.removeAt(oldIndex);
    playerList.insert(newIndex, item);
    widget.client.reorder(playerList);
  }

  _onStart() {
    widget.client.start();
    setState(() => starting = true);
    Timer(const Duration(milliseconds: 10000), () {
      if (!mounted) {
        debugPrint(
            "Game has started successfully or user has left the screen"); //In either case, we do nothing
        return;
      }
      setState(() => starting = false);
    });
  }

  _forceOnStart(BuildContext context) {
    //FORCING THE JOIN OF THE NEXT PAGE - THIS IS PURELY FOR TESTING PURPOSES
    widget.client.start();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Game(client: widget.client, id: 0, isHost: true),
      ),
    );
  }
}
