import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:dart_ipify/dart_ipify.dart';

class Player {
  int port;
  final int hostPort;
  final String hostIp;

  Player(this.port, this.hostIp, this.hostPort) {
    port = 46100;
    join(hostPort, hostIp);
  }

  // Send player data
  join(int hostPort, String hostIp) {
    // TODO: see if sourcePort is necessary
    Socket.connect(hostIp, hostPort, sourceAddress: InternetAddress.anyIPv4).then((Socket server) {

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
          start();
          break;
        case "pause":
          pause();
          break;
        case "next":
          next();
          break;
        case "join":
          joinGame();
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
    Socket.connect(hostIp, obj["port"], sourceAddress: InternetAddress.anyIPv4, sourcePort: 0).then((Socket server) {

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

  joinGame() {
    debugPrint("oi");
  }
}
