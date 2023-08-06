import 'dart:convert';
import '../util/player.dart';
import 'dart:io';
import '../util/gamestate.dart';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:dart_ipify/dart_ipify.dart';

class Host {
  final int port = 38383;
  late String roomCode;
  GameState gameState;

  Host({required this.gameState}) {
    roomCode = 'FHQW';
    listen(port);
  }

  listen(int port) {
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

      debugPrint('Listening');

      // Listen
      server.listen((Socket socket) {
        interpret(socket);
      });
    });
  }

  // Interpret the call and call the appropriate method
  interpret(Socket socket) {
    socket.listen((List<int> data) {
      // Convert the message to a JSON object
      const JsonDecoder decoder = JsonDecoder();
      final String message = String.fromCharCodes(data).trim();
      final Map<String, dynamic> obj = decoder.convert(message);
      debugPrint('I am the host, I received object: $obj');

      // Call the appropriate method
      switch (obj["call"]) {
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
          onJoinGame(socket, obj);
          break;
        default:
          throw Error();
      }

      // Handle errors
    }, onError: (error) {
      debugPrint('Error listening to client: $error');
    }, onDone: () {
      debugPrint('Client disconnected');
      socket.close();
    });
  }

  String getRoomCode() {
    return roomCode;
  }

  bool onJoinGame(Socket socket, Map<String, dynamic> obj) {
    if (obj["roomCode"] == roomCode) {
      Player player = Player(
          name: obj["gameState"]["players"][0]["name"],
          ip: socket.remoteAddress.toString());
      player.time = gameState.initTime.toDouble();
      gameState.addPlayer(player);
      socket.write('''{
        "status": "200",
        "call": "join",
        "gameState" : $gameState
      }
      ''');
      return true;
    } else {
      socket.write('{"status": "403"}');
      return false;
    }
  }

  String onStart(Map<String, dynamic> obj) {
    debugPrint("Host onStart");
    return 'oi';
  }

  String onPause(Map<String, dynamic> obj) {
    debugPrint("Host onPause");
    return 'oi';
  }

  String onNext(Map<String, dynamic> obj) {
    debugPrint("Host onNext");
    return 'oi';
  }
}
