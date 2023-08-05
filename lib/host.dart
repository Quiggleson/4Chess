import 'dart:convert';
import 'dart:io';
import 'gamestate.dart';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:dart_ipify/dart_ipify.dart';

class Host {
  final int port;
  GameState gameState;

  Host({this.port = 38383, required this.gameState}) {
    listen(port);
  }

  listen(int port) async {
    // Start the server
    ServerSocket.bind(InternetAddress.anyIPv4, port)
        .then((ServerSocket server) {
      // Print ip if in debug mode
      final info = NetworkInfo();
      info.getWifiIP().then((ip) {
        debugPrint('getwifiip: $ip');
      });
      Ipify.ipv4().then((ip) {
        debugPrint('ipify: $ip');
      });

      // Listen
      server.listen((Socket socket) async {
        String response = await interpret(socket);
        debugPrint('line 30 $response');
        socket.write(response);
        /*interpret(socket).then((String response) {
          print('line 30 sending $response');
          socket.write(response);
        });*/
        //socket.write(interpret(socket));
      });
    });
  }

  // Interpret the call and call the appropriate method
  Future<String> interpret(Socket socket) async {
    // Response to client
    Future<String> response;
    response = onJoinGame();

    socket.listen((List<int> data) async {
      // Convert the message to a JSON object
      const JsonDecoder decoder = JsonDecoder();
      final String message = String.fromCharCodes(data).trim();
      final Map<String, dynamic> obj = decoder.convert(message);
      debugPrint('I am the host, I received object: $obj');

      // Call the appropriate method
      /*switch (obj["call"]) {
        case "start":
          //response = onStart(obj);
          break;
        case "pause":
          //response = onPause(obj);
          break;
        case "next":
          //response = onNext(obj);
          break;
        case "join":
          response = onJoinGame(obj);
          debugPrint('Should be writing this: $response');
          break;
        default:
          throw Error();
      }*/

      // Handle errors
    }, onError: (error) {
      debugPrint('Error listening to client: $error');
    }, onDone: () {
      debugPrint('Client disconnected');
      socket.close();
    });

    debugPrint('I am the server; should be sending ${await response!}');
    // Return response
    return await response;
  }

  String getRoomCode() {
    return "ZOLF";
  }

  String onStart(Map<String, dynamic> obj) {
    debugPrint("oi");
    return 'oi';
  }

  String onPause(Map<String, dynamic> obj) {
    debugPrint("oi");
    return 'oi';
  }

  String onNext(Map<String, dynamic> obj) {
    debugPrint("oi");
    return 'oi';
  }

  Future<String> onJoinGame(/*Map<String, dynamic>? obj*/) async {
    String response = 'perhaps an error?';

    try {
      final socket = await ServerSocket.bind('0.0.0.0', 0);
      final port = socket.port;

      response = ''' {
      "call": "port",
      "port": $port
      }
    ''';

      debugPrint('line 104 $response');
    } catch (e) {
      debugPrint('An error occurred: $e');
    }

    debugPrint('line 106 $response');
    return response;
  }
}
