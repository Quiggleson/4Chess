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
  List<Socket> sockets = [];

  Host({required this.gameState}) {
    roomCode = 'FHQW';
    listen(port);
  }

  listen(int port) {
    // Start the server
    ServerSocket.bind(InternetAddress.anyIPv4, port)
        .then((ServerSocket server) {
      debugPrint('the address frfr: ${server.address.address.toString()}');

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
        if (!sockets.contains(socket)) sockets.add(socket);
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
          updateGameState(obj["gameState"]);
          onStart(obj);
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
        case "reorder":
          updateGameState(obj["gameState"]);
          onReorder(obj);
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

  updateGameState(Map<String, dynamic> gameState) {
    this.gameState.initTime = gameState["initTime"];
    this.gameState.increment = gameState["increment"];
    this.gameState.status = GameStatus.values
        .firstWhere((e) => e.toString() == gameState["status"]);
    List<Player> players = [];
    for (dynamic d in gameState["players"]) {
      debugPrint('Host adding player $d');
      players.add(Player(
          ip: d["ip"],
          name: d["name"],
          status: PlayerStatus.values
              .firstWhere((e) => e.toString() == d["status"]),
          time: d["time"]));
    }
    this.gameState.players = players;
  }

  bool onJoinGame(Socket socket, Map<String, dynamic> obj) {
    if (obj["roomCode"] == roomCode) {
      Player player = Player(
          name: obj["gameState"]["players"][0]["name"],
          ip: socket.remoteAddress.toString());
      player.time = gameState.initTime.toDouble();
      gameState.addPlayer(player);
      sockets.forEach((s) {
        s.write('''{
        "status": "200",
        "call": "join",
        "gameState" : $gameState
        }
      ''');
      });
      return true;
    } else {
      socket.write('{"status": "403"}');
      return false;
    }
  }

  bool onStart(Map<String, dynamic> obj) {
    debugPrint("Host onStart");
    sockets.forEach((socket) => socket.write('''{
        "status": "200",
        "call": "start",
        "gameState": $gameState
      }'''));
    return true;
  }

  String onPause(Map<String, dynamic> obj) {
    debugPrint("Host onPause");
    return 'oi';
  }

  String onNext(Map<String, dynamic> obj) {
    debugPrint("Host onNext");
    return 'oi';
  }

  bool onReorder(Map<String, dynamic> obj) {
    sockets.forEach((socket) => socket.write('''{
        "status": "200",
        "call": "reorder",
        "gameState": $gameState
      }'''));
    return true;
  }
}
