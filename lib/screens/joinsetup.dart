import 'package:flutter/material.dart';
import 'package:fourchess/screens/joinlobby.dart';
import 'package:fourchess/theme/fc_colors.dart';
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
  String _gameCode = "";
  bool loading = false;
  bool error = false;
  bool invalidGameCode = false;

  FocusNode nameFocusNode = FocusNode();
  FocusNode gameCodeFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: FCAppBar(title: Text(AppLocalizations.of(context)!.joinGame)),
        body: Padding(
            padding: const EdgeInsets.all(30),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(AppLocalizations.of(context)!.joinInstructions,
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center),
              const Padding(padding: EdgeInsets.only(top: 30)),
              Expanded(
                child: ListView(
                    physics: const OnlyOnFocusScrollPhysics(),
                    children: [
                      FCTextField(
                        focusNode: nameFocusNode,
                        hintText: AppLocalizations.of(context)!.name,
                        onChanged: (value) => setState(() => _name = value),
                        maxLength: 12,
                      ),
                      const Padding(padding: EdgeInsets.only(top: 30)),
                      Visibility(
                          visible: invalidGameCode,
                          child: Text(
                              AppLocalizations.of(context)!.invalidGamecode,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 16, color: FCColors.error))),
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      FCTextField(
                        focusNode: gameCodeFocusNode,
                        scrollPadding: const EdgeInsets.only(
                            bottom: double
                                .infinity), //Makes sure the counter text is in view
                        hintText: AppLocalizations.of(context)!.gameCode,
                        onChanged: (value) => setState(() => _gameCode = value),
                        maxLength: 4,
                      ),
                    ]),
              ),
              SizedBox(
                  height: nameFocusNode.hasFocus
                      ? 0
                      : MediaQuery.of(context).viewInsets.bottom * .9),
              Visibility(
                  visible: error,
                  child: Text(AppLocalizations.of(context)!.unableToCreate,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, color: FCColors.error))),
              const Padding(padding: EdgeInsets.only(top: 10)),
              loading
                  ? const FCLoadingAnimation()
                  : FCButton(
                      onPressed: _name.isEmpty || _gameCode.length < 4
                          ? null
                          : () => _onJoin(context),
                      child: Text(AppLocalizations.of(context)!.join)),
            ])));
  }

  _onJoin(BuildContext context) {
    //When user presses "JOIN GAME" to join a hosted game
    // GameState gameState =
    //GameState(players: <Player>[], status: GameStatus.setup);
    debugPrint('Making a new client');
    Client client;

    try {
      client = Client(
        name: _name,
        gameCode: _gameCode,
      ); // No longer need this, constructor takes care of it gameState: gameState);
      // client.joinGame(_gameCode); Moved this to client constructor since there would never be a client that doesn't join
    } catch (e) {
      setState(() {
        if (e is FormatException) {
          invalidGameCode = true;
        } else {
          error = true;
        }
      });

      return;
    }

    setState(() {
      loading = true;
      error = false;
      invalidGameCode = false;
    });

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
                  JoinLobby(gameCode: _gameCode, client: client)),
        );
      }

      if (elapsedTime > 10 && mounted) {
        //We have taken more than 10 seconds to connect, probably a network
        //issue
        timer.cancel();
        setState(() {
          error = true;
          loading = false;
        });

        debugPrint("ERROR HAS BEEN REACHED: ${error.toString()}");
      }
    });

    //FORCING THE NEXT PAGE - PURELY FOR TESTING PURPOSES
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => JoinLobby(
    //       client: client,
    //       gameCode: _gameCode,
    //     ),
    //   ),
    // );
  }
}
