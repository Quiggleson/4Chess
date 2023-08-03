import 'package:flutter/material.dart';
import 'package:fourchess/screens/hostlobby.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'package:fourchess/widgets/fc_dropdownbutton.dart';
import 'package:fourchess/widgets/fc_textfield.dart';
import '../widgets/fc_button.dart';

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
                onChanged: (value) => _name = value,
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
                  onPressed: () => {
                        //GameState gameState = new GameState( _dropDownValue.timeControl, _dropDownValue.increment, <Player>[], GameStatus.starting)
                        //Host host = new Host(gameState)
                        //String code = host.getRoomCode()
                        //Client client = new Client(name, gameState)
                        //TRIGGER LOADING ANIMATION
                        //client.joinGame(code)
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            //builder: (context) => HostLobby(roomCode: initializerData.gameCode, client);
                            builder: (context) =>
                                const HostLobby(roomCode: "ZOLF"),
                          ),
                        )
                      },
                  child: const Text("CONFIRM")),
            ])));
  }
}

class _TimeControl {
  _TimeControl(this.timeControl, this.increment, this.display);

  final double timeControl;
  final int increment;
  final String display;
}
