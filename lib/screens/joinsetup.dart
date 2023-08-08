import 'package:flutter/material.dart';
import 'package:fourchess/screens/joinlobby.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'package:fourchess/widgets/fc_textfield.dart';
import '../backend/client.dart';
import '../util/gamestate.dart';
import '../util/player.dart';
import '../widgets/fc_button.dart';
import 'dart:async';

class JoinSetup extends StatefulWidget {
  const JoinSetup({super.key});
  @override
  JoinSetupState createState() => JoinSetupState();
}

//Todo: CENTER BUTTONS AND MOVE
class JoinSetupState extends State<JoinSetup> {
  String _name = "";
  String _roomCode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: FCAppBar(title: const Text("JOIN GAME")),
        body: Padding(
            padding: const EdgeInsets.all(40),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              const Text("PICK A NAME AND ENTER A CODE TO JOIN A ROOM",
                  style: TextStyle(fontSize: 28), textAlign: TextAlign.center),
              const Padding(padding: EdgeInsets.only(top: 40)),
              FCTextField(
                hintText: "NAME",
                onChanged: (value) => setState(() => _name = value),
                maxLength: 12,
              ),
              const Padding(padding: EdgeInsets.only(top: 40)),
              FCTextField(
                hintText: "ROOM CODE",
                onChanged: (value) => setState(() => _roomCode = value),
                maxLength: 4,
              ),
              const Spacer(),
              FCButton(
                  onPressed: _name.isEmpty || _roomCode.length < 4
                      ? null
                      : () => _onJoin(context),
                  child: const Text("JOIN")),
            ])));
  }

  _onJoin(BuildContext context) {
    //When user presses "JOIN GAME" to join a hosted game
    // GameState gameState =
    //GameState(players: <Player>[], status: GameStatus.setup);
    print('Making a new client');
    Client client = Client(
      name: _name,
      roomCode: _roomCode,
    ); // No longer need this, constructor takes care of it gameState: gameState);
    // client.joinGame(_roomCode); Moved this to client constructor since there would never be a client that doesn't join

    //Trigger loading animation

    double elapsedTime = 0;

    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      //checks twice a second to see if have successfully joined the game
      elapsedTime += .5;

      if (client.isModified) {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) =>
                  JoinLobby(roomCode: _roomCode, client: client)),
        );

        timer.cancel();
      }

      debugPrint("Time elapsed since attempting to join game: $elapsedTime");

      if (elapsedTime >= 10) {
        //We have taken more than 10 seconds to connect, probably a network
        //issue
        debugPrint("Failed to join game");
        timer.cancel();
      }
    });

    //FORCING THE JOIN OF THE NEXT PAGE - THIS IS PURELY FOR TESTING PURPOSES
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
