import 'package:flutter/material.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'package:fourchess/widgets/fc_dropdownbutton.dart';
import 'package:fourchess/widgets/fc_textfield.dart';
import '../backend/client.dart';
import '../util/gamestate.dart';
import '../backend/host.dart';
import '../widgets/fc_button.dart';
import '../util/player.dart';
import 'hostlobby.dart';
import 'dart:async';

class HostSetup extends StatefulWidget {
  const HostSetup({super.key});
  @override
  HostSetupState createState() => HostSetupState();
}

class HostSetupState extends State<HostSetup> {
  String _name = "";

  final List<_TimeControl> _timeControls = [
    _TimeControl(180, 3, "3:00 + 2"),
    _TimeControl(60, 0, "1:00"),
    _TimeControl(180, 0, "3:00"),
    _TimeControl(600, 0, "10:00")
  ];

  _TimeControl? _dropdownValue;

  //FINISH THIS
  @override
  Widget build(BuildContext context) {
    _dropdownValue ??= _timeControls[0];

    return Scaffold(
        appBar: FCAppBar(title: const Text("HOST GAME")),
        body: Padding(
            padding: const EdgeInsets.all(40),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              const Text(
                  "PICK A NAME AND TIME CONTROL, THEN CONFIRM TO GENERATE A GAME CODE",
                  style: TextStyle(fontSize: 28),
                  textAlign: TextAlign.center),
              const Padding(padding: EdgeInsets.only(top: 40)),
              FCTextField(
                hintText: "NAME",
                onChanged: (value) => setState(() => _name = value),
              ),
              const Padding(padding: EdgeInsets.only(top: 40)),
              FCDropDownButton(
                value: _dropdownValue,
                items: [
                  for (int i = 0; i < _timeControls.length; i++)
                    DropdownMenuItem(
                        value: _timeControls[i],
                        child: Center(child: Text(_timeControls[i].display))),
                ],
                onChanged: (value) => {
                  if (value is _TimeControl)
                    {setState(() => _dropdownValue = value)}
                },
              ),
              const Spacer(),
              FCButton(
                  onPressed: _name.isEmpty ? null : () => _onConfirm(context),
                  child: const Text("CONFIRM")),
            ])));
  }

  _onConfirm(BuildContext context) {
    //When user presses
    GameState gameState = GameState(
      initTime: _dropdownValue!.timeControl,
      increment: _dropdownValue!.increment,
      players: <Player>[],
    );
    //status: GameStatus.setup); Don't need to set initial gameStatus, always setup
    Host host = Host(gameState: gameState);
    String code = host.getRoomCode();
    Client client = Client(name: _name, roomCode: host.getRoomCode());

    //Trigger loading animation

    double elapsedTime = 0;

    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      //checks twice a second to see if have successfully joined the game
      elapsedTime += .5;

      if (client.isModified) {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => HostLobby(roomCode: code, client: client)),
        );
        timer.cancel();
        client.isModified = false;
      }

      debugPrint("Time elapsed since attempting to join game: $elapsedTime");

      if (elapsedTime > 10) {
        //We have taken more than 10 seconds to connect, probably a network
        //issue
        debugPrint("Failed to join game");
        timer.cancel();
      }
    });

    //FORCING THE JOIN OF THE NEXT PAGE - THIS IS PURELY FOR TESTING PURPOSES
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => HostLobby(roomCode: code, client: client)),
    );
  }
}

class _TimeControl {
  _TimeControl(this.timeControl, this.increment, this.display);

  final int timeControl;
  final int increment;
  final String display;
}
