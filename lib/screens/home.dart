import 'package:flutter/material.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import '../widgets/fc_button.dart';
import '../widgets/fc_dropdownbutton.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: FCAppBar(title: const Text("HOST GAME")),
        body: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(children: [
              FCDropdownButton(),
              FCButton(child: const Text("JOIN GAME"), onPressed: () => {})
            ])));
  }
}
