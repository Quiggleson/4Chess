import 'package:flutter/material.dart';
import 'client.dart';
import 'server.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyHomePage()); //placeholder
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Client? client;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Scaffold(
              body: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column (
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    ElevatedButton(
                        onPressed: () {
                          Server('0.0.0.0', 48190);
                        },
                        child: Text('Host'),
                    ),
                    SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          client = Client('192.168.6.107', 48190);
                        },
                        child: Text('Join'),
                      ),ElevatedButton(
                        onPressed: () {
                          // Note: connect to the hosts local ip address
                          (client != null) ? client!.sendData('look at the data') : debugPrint('client is down)');
                          //client?.sendData('Houston, we\'ve got data') ?? debugPrint('Alas the client is not set up');
                        },
                        child: Text('Send data'),
                      ),
                  ],
                  ),
                ],
              ),
            ),
          );
        },
    );
  }
}