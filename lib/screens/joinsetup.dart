import 'package:flutter/material.dart';
import 'package:fourchess/screens/joinlobby.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'package:fourchess/widgets/fc_textfield.dart';
import '../widgets/fc_button.dart';

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
                onChanged: (value) => _name = value,
                maxLength: 12,
              ),
              const Padding(padding: EdgeInsets.only(top: 40)),
              FCTextField(
                hintText: "ROOM CODE",
                onChanged: (value) => _roomCode = value,
                maxLength: 4,
              ),
              const Spacer(),
              FCButton(
                  onPressed: () => {
                        //GameState gameState = new GameState(players: <Player>[], status: GameStatus.starting) ???
                        //Client client = new Client(name, gameState)
                        //TRIGGER LOADING ANIMATION
                        //client.joinGame(code)
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            //builder: (context) => JoinLobby(client),
                            builder: (context) =>
                                JoinLobby(roomCode: _roomCode),
                          ),
                        )
                      },
                  child: const Text("JOIN")),
            ])));
  }
}