import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'player.dart';
import 'gamestate.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:dart_ipify/dart_ipify.dart';

class Client {
  int port;
  final int hostPort;
  final String hostIp;
  GameState gameState;
  bool isModified = false;

  Client(this.port, this.hostIp, this.hostPort, this.gameState) {
    port = 46100;
    join(hostPort, hostIp);
  }

  // Send player data
  join(int hostPort, String hostIp) {
    Socket.connect(hostIp, hostPort, sourceAddress: InternetAddress.anyIPv4)
        .then((Socket server) {
      // Message to send to host
      String message = '''
          {
            "call": "join"
          }
        ''';

      // Send the message
      server.write(message);

      // Interpret the response
      interpret(server);
    }, onError: (error) {
      debugPrint('$error');
    });
  }

  // Listen for messages from the host
  listen(int port) {
    // Start the listener
    ServerSocket.bind(InternetAddress.anyIPv4, port)
        .then((ServerSocket listener) {
      // Print ip if in debug mode
      final info = NetworkInfo();
      info.getWifiIP().then((ip) {
        debugPrint('getwifiip: $ip');
      });
      Ipify.ipv4().then((ip) {
        debugPrint('ipify: $ip');
      });

      // Listen
      listener.listen((Socket socket) {
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
      debugPrint('Received: $message');
      final Map<String, dynamic> obj = decoder.convert(message);

      // Call the appropriate method
      switch (obj["call"]) {
        case "start":
          break;
        case "pause":
          break;
        case "next":
          break;
        case "join":
          break;
        case "port":
          newPort(obj);
          break;
        default:
          throw Error();
      }
    }, onError: (error) {
      debugPrint('Error listening to host: $error');
    }, onDone: () {
      debugPrint('Client disconnected');
      socket.close();
    });
  }

  newPort(Map<String, dynamic> obj) {
    debugPrint('I am trying to connect to the hostPort ${obj["port"]}');
    Socket.connect(hostIp, obj["port"],
            sourceAddress: InternetAddress.anyIPv4, sourcePort: 0)
        .then((Socket server) {
      // Interpret the response
      interpret(server);
    }, onError: (error) {
      debugPrint('$error');
    });
  }

  start() {
    debugPrint("oi");
  }

  pause() {
    debugPrint("oi");
  }

  next() {
    debugPrint("oi");
  }

  reorder(List<Player> players) {
    debugPrint("oi");
  }

  joinGame(String code, String name) {
    debugPrint("oi");
  }

  lost() {
    debugPrint("oi");
  }

  reset() {
    debugPrint("oi");
  }

  GameState getGameState() {
    return gameState;
  }
}
