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

//TODO: CENTER BUTTONS AND MOVE
class HostSetupState extends State<HostSetup> {
  String _name = "";
  String _dropdownValue = "3:00+2";

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
              FCTextField(
                hintText: "NAME",
                onChanged: (value) => _name = value,
              ),
              const Padding(padding: EdgeInsets.only(top: 40)),
              FCDropDownButton(
                value: _dropdownValue,
                items: const [
                  DropdownMenuItem(
                      value: "3:00+2", child: Center(child: Text("3:00+2"))),
                  DropdownMenuItem(
                    value: "1:00",
                    child: Center(child: Text("1:00")),
                  ),
                  DropdownMenuItem(
                    value: "3:00",
                    child: Center(child: Text("3:00")),
                  ),
                  DropdownMenuItem(
                    value: "10:00",
                    child: Center(child: Text("10:00")),
                  ),
                ],
                onChanged: (value) => {
                  if (value is String) {setState(() => _dropdownValue = value)}
                },
              ),
              const Spacer(),
              FCButton(
                  onPressed: () => {
                        //Scan for room code
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HostLobby(),
                          ),
                        )
                      },
                  child: const Text("CONFIRM")),
            ])));
  }
}
