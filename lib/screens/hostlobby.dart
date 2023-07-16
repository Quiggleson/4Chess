import 'package:flutter/material.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'package:fourchess/widgets/fc_button.dart';
import 'package:fourchess/widgets/fc_numbereditem.dart';
import 'dart:ui';

class HostLobby extends StatefulWidget {
  HostLobby({super.key});

  @override
  HostLobbyState createState() => HostLobbyState();
}

class HostLobbyState extends State<HostLobby> {
  String _roomcode = "ZOLF";
  int _numPlayersJoined = 2;

  final List _names = ["WALDO", "AARON", "DEVEN", "ROBERT"];

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: FCAppBar(
          title: Text("HOST GAME\nCODE: $_roomcode"),
          toolbarHeight: 180,
        ),
        body: Padding(
            padding: const EdgeInsets.all(40),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Text("WAITING FOR ${4 - _numPlayersJoined} PLAYERS",
                  style: const TextStyle(fontSize: 28),
                  textAlign: TextAlign.center),
              const Padding(padding: EdgeInsets.only(top: 40)),
              Expanded(
                  child: ReorderableListView(
                proxyDecorator: _proxyDecorator,
                children: <Widget>[
                  for (int i = 0; i < 4; i++)
                    FCNumberedItem(
                        content: _names[i], number: i + 1, key: Key("$i"))
                ],
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    String item = _names.removeAt(oldIndex);
                    _names.insert(newIndex, item);

                    //SEND ORDER DATA TO CLIENTS
                  });
                },
              )),
              const Padding(padding: EdgeInsets.only(top: 40)),
              const Text("DRAG AND DROP NAMES TO CHANGE PLAYER ORDER",
                  style: TextStyle(fontSize: 28), textAlign: TextAlign.center),
              const Padding(padding: EdgeInsets.only(top: 40)),
              FCButton(onPressed: () => {}, child: const Text("START"))
            ])));
  }
}
