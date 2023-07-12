import 'package:flutter/material.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'package:fourchess/widgets/fc_textfield.dart';
import '../widgets/fc_button.dart';
import 'package:google_fonts/google_fonts.dart';

class HostSetup extends StatefulWidget {
  const HostSetup({super.key});
  @override
  HostSetupState createState() => HostSetupState();
}

//TODO: CENTER BUTTONS AND MOVE
class HostSetupState extends State<HostSetup> {
  String _name = "";

  @override
  Widget build(BuildContext context) {
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
              FCTextField(),
              const Spacer(),
              FCButton(onPressed: () => {}, child: const Text("CONFIRM")),
            ])));
  }
}
