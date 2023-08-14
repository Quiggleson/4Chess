import 'package:flutter/material.dart';
import 'package:fourchess/screens/hostsetup.dart';
import 'package:fourchess/screens/joinsetup.dart';
import '../widgets/fc_button.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(30),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("4Chess", style: TextStyle(fontSize: 96)),
              const Padding(padding: EdgeInsets.only(top: 40)),
              FCButton(
                  onPressed: () => {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const HostSetup(),
                          ),
                        )
                      },
                  child: const Text("HOST GAME")),
              const Padding(padding: EdgeInsets.only(top: 20)),
              FCButton(
                  onPressed: () => {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const JoinSetup(),
                          ),
                        )
                      },
                  child: const Text("JOIN GAME"))
            ])));
  }
}
