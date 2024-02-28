import 'package:flutter/material.dart';
import 'package:fourchess/screens/joinlobby.dart';
import 'package:fourchess/theme/fc_colors.dart';
import 'package:fourchess/widgets/debugonly.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'package:fourchess/widgets/fc_textfield.dart';
import '../backend/client.dart';
import '../widgets/fc_button.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/fc_loadinganimation.dart';

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
  bool error = false;
  bool invalidRoomCode = false;

  static const int _roomcodeMaxLength = 6;
  static const int _nameMaxLength = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: FCAppBar(title: Text(AppLocalizations.of(context)!.joinGame)),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(AppLocalizations.of(context)!.joinInstructions,
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center),
              const Padding(padding: EdgeInsets.only(top: 30)),
              FCTextField(
                hintText: AppLocalizations.of(context)!.name,
                onChanged: (value) => setState(() => _name = value),
                maxLength: _nameMaxLength,
              ),
              Visibility(
                  visible: invalidRoomCode,
                  child: Text(AppLocalizations.of(context)!.invalidRoomCode,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, color: FCColors.error))),
              const Padding(padding: EdgeInsets.only(top: 10)),
              FCTextField(
                hintText: AppLocalizations.of(context)!.roomCode,
                onChanged: (value) => setState(() => _roomCode = value),
                maxLength: _roomcodeMaxLength,
              ),
              DebugOnly(text: "force start game", onPress: _forceOnJoin),
              Visibility(
                  visible: error,
                  child: Text(AppLocalizations.of(context)!.unableToJoin,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, color: FCColors.error))),
              const Padding(padding: EdgeInsets.only(top: 10)),
              loading
                  ? const FCLoadingAnimation()
                  : FCButton(
                      onPressed:
                          _name.isEmpty || _roomCode.length < _roomcodeMaxLength
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
        roomCode: _roomCode,
      );
      debugPrint('Join front end making client $_name');
    } catch (e) {
      setState(() {
        if (e is FormatException) {
          invalidRoomCode = true;
        } else {
          error = true;
        }
      });

      return;
    }

    //This phase will never cause duplicate listeners, as onJoin creates a new instance of Client
    void goToJoinLobby() {
      if (ModalRoute.of(context)!.isCurrent) {
        setState(() {
          loading = false;
          error = false;
          invalidRoomCode = false;
        });
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) =>
                  JoinLobby(roomCode: _roomCode, client: client)),
        );
      }
      client.removeListener(goToJoinLobby);
    }

    client.addListener(goToJoinLobby);

    setState(() {
      loading = true;
      error = false;
      invalidRoomCode = false;
    });

    Timer(const Duration(milliseconds: 10000), () {
      if (!ModalRoute.of(context)!.isCurrent) {
        debugPrint("User has left the join setup screen");
        return;
      }

      //We have taken more than 10 seconds to connect, probably a network
      //issue
      setState(() {
        error = true;
        loading = false;
      });
      debugPrint("ERROR HAS BEEN REACHED: ${error.toString()}");
    });
  }

  _forceOnJoin(BuildContext context) {
    //FORCING THE NEXT PAGE - PURELY FOR TESTING PURPOSES
    Client client;

    try {
      client = Client(
        name: _name,
        roomCode: _roomCode,
      );
      // No longer need this, constructor takes care of it gameState: gameState);
      // client.joinGame(_roomCode); Moved this to client constructor since there would never be a client that doesn't join
    } catch (e) {
      setState(() {
        if (e is FormatException) {
          invalidRoomCode = true;
        } else {
          error = true;
        }
      });

      return;
    }

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
