import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fourchess/theme/fc_colors.dart';
import 'package:fourchess/widgets/debugonly.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'package:fourchess/widgets/fc_dropdownbutton.dart';
import 'package:fourchess/widgets/fc_loadinganimation.dart';
import 'package:fourchess/widgets/fc_textfield.dart';
import '../backend/client.dart';
import '../util/gamestate.dart';
import '../backend/host.dart';
import '../widgets/fc_button.dart';
import '../util/player.dart';
import 'hostlobby.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  static const int _nameMaxLength = 12;

  bool loading = false;
  bool error = false;

  //FINISH THIS
  @override
  Widget build(BuildContext context) {
    _dropdownValue ??= _timeControls[0];

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: FCAppBar(title: Text(AppLocalizations.of(context)!.hostGame)),
        body: Padding(
            padding: const EdgeInsets.all(30),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(AppLocalizations.of(context)!.hostInstructions,
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center),
              const Padding(padding: EdgeInsets.only(top: 30)),
              FCTextField(
                maxLength: _nameMaxLength,
                hintText: AppLocalizations.of(context)!.name,
                onChanged: (value) => setState(() => _name = value),
              ),
              const Padding(padding: EdgeInsets.only(top: 30)),
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
              DebugOnly(text: "force start game", onPress: _forceOnConfirm),
              Visibility(
                  visible: error,
                  child: Text(AppLocalizations.of(context)!.unableToCreate,
                      style: const TextStyle(
                          fontSize: 16, color: FCColors.error))),
              const Padding(padding: EdgeInsets.only(top: 10)),
              loading
                  ? const FCLoadingAnimation()
                  : FCButton(
                      onPressed:
                          _name.isEmpty ? null : () => _onConfirm(context),
                      child: Text(AppLocalizations.of(context)!.confirm)),
            ])));
  }

  _onConfirm(BuildContext context) async {
    //FORCING THE JOIN OF THE NEXT PAGE - THIS IS PURELY FOR TESTING PURPOSES
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //       builder: (context) => HostLobby(
    //           roomCode: "ABCD",
    //           client: Client(name: "Deven", roomCode: "ABCD"))),
    // );
    // return;

    setState(() {
      loading = true;
      error = false;
    });

    //When user presses
    GameState gameState = GameState(
      initTime: _dropdownValue!.timeControl,
      increment: _dropdownValue!.increment,
      players: <Player>[],
    );

    late Host host;
    late String code;
    late Client client;

    try {
      host = Host(gameState: gameState);
      code = await host.getRoomCode();
      client = Client(name: _name, roomCode: await host.getRoomCode());
      debugPrint('Host front end making client $_name');
    } catch (e) {
      loading = false;
      error = true;
      debugPrint(e.toString());
      return;
    }

    void goToHostLobby() {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => HostLobby(roomCode: code, client: client)),
        );
      }
      client.removeListener(goToHostLobby);
    }

    client.addListener(goToHostLobby);

    Timer(const Duration(milliseconds: 10000), () {
      if (!mounted) {
        debugPrint("User has left the host setup screen");
        return;
      }

      //We have taken more than 10 seconds to connect, probably a network
      //issue
      debugPrint("Failed to host game");
      setState(() {
        loading = false;
        error = true;
      });
    });
  }

  void _forceOnConfirm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => HostLobby(
              roomCode: "ABCDEF",
              client: Client(name: "Deven", roomCode: "ABCDEF"))),
    );
    return;
  }
}

class _TimeControl {
  _TimeControl(this.timeControl, this.increment, this.display);

  final int timeControl;
  final int increment;
  final String display;
}
