import 'package:flutter/material.dart';
import 'package:fourchess/screens/joinlobby.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'package:fourchess/widgets/fc_textfield.dart';
import '../backend/client.dart';
import '../widgets/fc_button.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/fc_loadinganimation.dart';
import '../widgets/only_on_focus_scroll_physics.dart';

class JoinSetup extends StatefulWidget {
  const JoinSetup({super.key});
  @override
  JoinSetupState createState() => JoinSetupState();
}

//Todo: CENTER BUTTONS AND MOVEs
class JoinSetupState extends State<JoinSetup> {
  String _name = "";
  String _roomCode = "";
  bool loading = false;

  FocusNode nameFocusNode = FocusNode();
  FocusNode roomCodeFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: FCAppBar(title: Text(AppLocalizations.of(context).joinGame)),
        body: Padding(
            padding: const EdgeInsets.all(30),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Text(AppLocalizations.of(context).joinInstructions,
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center),
              const Padding(padding: EdgeInsets.only(top: 30)),
              Expanded(
                child: ListView(
                    physics: const OnlyOnFocusScrollPhysics(),
                    children: [
                      FCTextField(
                        focusNode: nameFocusNode,
                        hintText: AppLocalizations.of(context).name,
                        onChanged: (value) => setState(() => _name = value),
                        maxLength: 12,
                      ),
                      const Padding(padding: EdgeInsets.only(top: 30)),
                      FCTextField(
                        focusNode: roomCodeFocusNode,
                        scrollPadding: const EdgeInsets.only(
                            bottom: double
                                .infinity), //Makes sure the counter text is in view
                        hintText: AppLocalizations.of(context).roomCode,
                        onChanged: (value) => setState(() => _roomCode = value),
                        maxLength: 4,
                      ),
                    ]),
              ),
              SizedBox(
                  height: nameFocusNode.hasFocus
                      ? 0
                      : MediaQuery.of(context).viewInsets.bottom * .9),
              loading
                  ? const FCLoadingAnimation()
                  : FCButton(
                      onPressed: _name.isEmpty || _roomCode.length < 4
                          ? null
                          : () => _onJoin(context),
                      child: Text(AppLocalizations.of(context).join)),
            ])));
  }

  _onJoin(BuildContext context) {
    //When user presses "JOIN GAME" to join a hosted game
    // GameState gameState =
    //GameState(players: <Player>[], status: GameStatus.setup);
    debugPrint('Making a new client');
    Client client = Client(
      name: _name,
      roomCode: _roomCode,
    ); // No longer need this, constructor takes care of it gameState: gameState);
    // client.joinGame(_roomCode); Moved this to client constructor since there would never be a client that doesn't join

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

      if (client.isDirty() && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) =>
                  JoinLobby(roomCode: _roomCode, client: client)),
        );
      }

      if (elapsedTime > 10 && mounted) {
        //We have taken more than 10 seconds to connect, probably a network
        //issue
        timer.cancel();
        setState(() => loading = false);
      }
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => JoinLobby(
          client: client,
          roomCode: _roomCode,
        ),
      ),
    );
  }
}
