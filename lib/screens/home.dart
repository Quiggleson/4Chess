import 'package:flutter/material.dart';
import 'package:fourchess/screens/hostsetup.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import '../widgets/fc_button.dart';
import '../widgets/fc_dropdownbutton.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  HomeState createState() => HomeState();
}

//TODO: CENTER BUTTONS AND MOVE
class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(40),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("4Chess", style: TextStyle(fontSize: 96)),
              const Padding(padding: EdgeInsets.only(top: 40)),
              FCButton(
                  onPressed: () => {
                        Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  const HostSetup(),
                            ))
                      },
                  child: const Text("HOST GAME")),
              const Padding(padding: EdgeInsets.only(top: 40)),
              FCButton(onPressed: () => {}, child: const Text("JOIN GAME"))
            ])));
  }
}
