import 'dart:convert';
import '../util/player.dart';
import 'dart:io';
import '../util/gamestate.dart';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';

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
      });

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

      // Call the appropriate method
      switch (obj["call"]) {
        case "start":
          updateGameState(obj["gameState"]);
          onStart(obj);
          break;
        case "togglePause":
          updateGameState(obj["gameState"]);
          onTogglePause(obj);
          break;
        case "startTimer":
          updateGameState(obj["gameState"]);
          onStartTimer(obj);
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
        case "reset":
          updateGameState(obj["gameState"]);
          onReset(obj);
        case "endGame":
          updateGameState(obj["gameState"]);
          onEndGame(obj);
        default:
          throw Error();
      }

      // Handle errors
    }, onError: (error) {
      debugPrint('Error listening to client: $error');
    }, onDone: () {
      debugPrint('Client disconnected');
      sockets.remove(socket);
      socket.close();
    });
  }

  Future<String> getRoomCode() async {
    final info = NetworkInfo();
    String? ip = await info.getWifiIP();

    debugPrint('getwifiip: $ip');
    List<String> parts = ip?.split('.') ?? ['0'];
    String code = '';
    for (var part in parts.sublist(1)) {
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
      String newip = socket.remoteAddress.address.toString();
      Player player = Player(
          name: obj["gameState"]["players"][0]["name"],
          ip: socket.remoteAddress.address.toString());
      player.time = gameState.initTime.toDouble();
      gameState.addPlayer(player);
      socket.write('''begin:{
        "status": "200",
        "call": "updateip",
        "newip" : "$newip"
        }
      ''');
      for (Socket s in sockets) {
        s.write('''begin:{
        "status": "200",
        "call": "join",
        "gameState" : $gameState
        }
      ''');
      }
      return true;
    } else {
      socket.write('begin:{"status": "403"}');
      return false;
    }
  }

  bool onStart(Map<String, dynamic> obj) {
    debugPrint("Host onStart");
    sockets.forEach((socket) => socket.write('''begin:{
        "status": "200",
        "call": "start",
        "gameState": $gameState
      }'''));
    return true;
  }

  bool onStartTimer(Map<String, dynamic> obj) {
    debugPrint("Host onStartTimer");
    sockets.forEach((socket) => socket.write('''begin:{
        "status": "200",
        "call": "startTimer",
        "gameState": $gameState
      }'''));
    return true;
  }

  bool onTogglePause(Map<String, dynamic> obj) {
    debugPrint("Host onPause");
    sockets.forEach((socket) => socket.write('''begin:{
        "status": "200",
        "call": "togglePause",
        "gameState": $gameState
      }'''));
    return true;
  }

  bool onNext(Map<String, dynamic> obj) {
    debugPrint("Host onNext");
    sockets.forEach((socket) => socket.write('''begin:{
        "status": "200",
        "call": "next",
        "gameState": $gameState
      }'''));
    return true;
  }

  bool onReset(Map<String, dynamic> obj) {
    debugPrint("Host onReset");
    sockets.forEach((socket) => socket.write('''begin:{
        "status": "200",
        "call": "reset",
        "gameState": $gameState
      }'''));
    return true;
  }

  bool onEndGame(Map<String, dynamic> obj) {
    debugPrint("Host onEndGame");
    sockets.forEach((socket) => socket.write('''begin:{
        "status": "200",
        "call": "endGame",
        "gameState": $gameState
      }'''));
    stop();
    return true;
  }

  bool onReorder(Map<String, dynamic> obj) {
    sockets.forEach((socket) => socket.write('''begin:{
        "status": "200",
        "call": "reorder",
        "gameState": $gameState
      }'''));
    return true;
  }

  stop() {
    debugPrint("Stopping host server");
    server.close();
  }
}
