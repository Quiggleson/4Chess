import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'host.dart';
import 'player.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String buttonText = "";
  String textFieldValue = "";

  void _onJoinPressed() {
    setState(() {
      buttonText = "Join";
    });

    // Placeholder function to use the text field value
    _placeholderJoinFunction(textFieldValue);
  }

  void _placeholderJoinFunction(String parameter) {
    // Implement your logic here for handling the 'join' button press
    print("Join button pressed with parameter: $parameter");
  }

  void _onHostPressed() {
    setState(() {
      buttonText = "Host";
    });

    // Placeholder function to handle 'host' button press
    _placeholderHostFunction();
  }

  void _placeholderHostFunction() {
    // Implement your logic here for handling the 'host' button press
    print("Host button pressed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Button and Text Field Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttonText.isNotEmpty ? "Selected: $buttonText" : "",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Player(48100,textFieldValue,38383);
              },
              child: Text('Join'),
            ),
            ElevatedButton(
              onPressed: () {
                Host(38383);
              },
              child: Text('Host'),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    textFieldValue = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Text Field',
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Placeholder function for the 'start' button
                print("Start button pressed");
              },
              child: Text('Start'),
            ),
            ElevatedButton(
              onPressed: () {
                // Placeholder function for the 'pause' button
                print("Pause button pressed");
              },
              child: Text('Pause'),
            ),
            ElevatedButton(
              onPressed: () {
                // Placeholder function for the 'next' button
                print("Next button pressed");
              },
              child: Text('Next'),
            ),
            ElevatedButton(
              onPressed: () {
                // Placeholder function for the 'join' button (different from above)
                var info = NetworkInfo();
                info.getWifiIP().then((ip) {
                  print("The ip is: $ip");
                });
              },
              child: Text('Get ip'),
            ),
            ElevatedButton(
              onPressed: () {
                // Placeholder function for the 'join' button (different from above)
                //Host.onJoinGame(null);
                print('Lol jk this is not join');
              },
              child: Text('onJoinFunction'),
            ),
          ],
        ),
      ),
    );
  }
}
