import 'dart:convert';
import '../util/player.dart';
import 'dart:io';
import '../util/gamestate.dart';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:dart_ipify/dart_ipify.dart';

class Host {
  final int port = 38383;
  //late Future<String> roomCode;
  late String roomCode;
  late ServerSocket server;
  GameState gameState;
  List<Socket> sockets = [];

  Host({required this.gameState}) {
    //roomCode = getRoomCode();
    roomCode = 'FHQW';
    listen(port);
  }

  listen(int port) {
    // Start the server
    ServerSocket.bind(InternetAddress.anyIPv4, port)
        .then((ServerSocket server) {
      this.server = server;
      // Print ip if in debug mode
      final info = NetworkInfo();
      info.getWifiIP().then((ip) {
        debugPrint('getwifiip: $ip');
        List<String> parts = ip?.split('.') ?? ['0'];
        String code = '';
        for (var part in parts.sublist(2)) {
          int i = int.parse(part);
          code = code + i.toRadixString(16).padLeft(2, '0');
        }
        //roomCode = code;
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
      final String message = utf8.decode(data).trim();
      final Map<String, dynamic> obj = decoder.convert(message);
      debugPrint('I am the host, I received object: $obj');

      // Call the appropriate method
      switch (obj["call"]) {
        case "start":
          updateGameState(obj["gameState"]);
          onStart(obj);
          break;
        case "pause":
          updateGameState(obj["gameState"]);
          onPause(obj);
          break;
        case "next":
          updateGameState(obj["gameState"]);
          onNext(obj);
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

  Future<String> getRoomCode() async {
    final info = NetworkInfo();
    String? ip = await info.getWifiIP();

    debugPrint('getwifiip: $ip');
    List<String> parts = ip?.split('.') ?? ['0'];
    String code = '';
    for (var part in parts.sublist(2)) {
      int i = int.parse(part);
      code = code + i.toRadixString(16).padLeft(2, '0').toUpperCase();
    }
    roomCode = code;
    return code;
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
          ip: socket.remoteAddress.address.toString());
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

  bool onPause(Map<String, dynamic> obj) {
    debugPrint("Host onPause");
    sockets.forEach((socket) => socket.write('''{
        "status": "200",
        "call": "pause",
        "gameState": $gameState
      }'''));
    return true;
  }

  bool onNext(Map<String, dynamic> obj) {
    debugPrint("Host onNext");
    sockets.forEach((socket) => socket.write('''{
        "status": "200",
        "call": "next",
        "gameState": $gameState
      }'''));
    return true;
  }

  bool onReorder(Map<String, dynamic> obj) {
    sockets.forEach((socket) => socket.write('''{
        "status": "200",
        "call": "reorder",
        "gameState": $gameState
      }'''));
    return true;
  }

  stop() {
    server.close();
  }
}
