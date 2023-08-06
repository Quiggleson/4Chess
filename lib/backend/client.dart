import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../util/player.dart';
import '../util/gamestate.dart';

class Client {
  final int port = 46100;
  late final String ip;
  // Flutter gets mad for no reason when this is late so throw a dummy gamestate in there
  GameState gameState = GameState();
  late Socket socket;
  bool isModified = false;

  Client({required String name, required String roomCode}) {
    // Connect to host - populate ip, gameState, and socket
    Socket.connect(getHostIp(), 38383, sourceAddress: InternetAddress.anyIPv4)
        .then((Socket socket) {
      debugPrint('Client has connected to server');
      // Populate socket
      this.socket = socket;

      // Populate ip
      ip = socket.address.address.toString();

      // Make a player for gameState
      Player player = Player(name: name, ip: ip);

      // Populate gameState
      gameState = GameState(players: [player]);

      // Join game
      join(roomCode);
    }, onError: (err) {
      debugPrint('Oi there was an error connecting, $err');
    });
  }

  String getHostIp() {
    return '192.168.6.242';
  }

  bool checkData() {
    if (isModified) {
      isModified = false;
      return true;
      //any other logic required
    }
    return false;
  }

  // Send player data
  join(String roomCode) {
    // Message to send to host
    String message = '''
          {
            "call": "join",
            "roomCode": "$roomCode",
            "gameState" : $gameState
          }
        ''';

    debugPrint('Sending $message');
    // Send the message
    socket.write(message);

    // Listen for response
    socket.listen((List<int> data) {
      // Convert the message to a JSON object
      const JsonDecoder decoder = JsonDecoder();
      final String message = String.fromCharCodes(data).trim();
      debugPrint('Received: $message');
      final Map<String, dynamic> obj = decoder.convert(message);
      debugPrint('status: ${obj["status"]}');
      if (obj["status"] == '200') {
        update(obj["gameState"]);
      } else {
        debugPrint(obj.toString());
      }
    });
  }

  update(Map<String, dynamic> gameState) {
    // Check if the proposed gameState is different and update the isModified flag
    if (gameState != this.gameState.getJson()) {
      this.gameState.initTime = gameState["initTime"];
      this.gameState.increment = gameState["increment"];
      this.gameState.status = GameStatus.values
          .firstWhere((e) => e.toString() == gameState["status"]);
      List<Player> players = [];
      for (dynamic d in gameState["players"]) {
        players.add(Player(
            ip: d["ip"],
            name: d["name"],
            status: PlayerStatus.values
                .firstWhere((e) => e.toString() == d["status"]),
            time: d["time"]));
      }
      this.gameState.players = players;
      isModified = true;
    }
  }

  // Interpret the call and call the appropriate method
  interpret() {
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

  start() {
    debugPrint("Client Start");
  }

  pause() {
    debugPrint("Client Pause");
  }

  next(double time) {
    debugPrint("Client Next");
  }

  reorder(List<Player> players) {
    debugPrint("Client Reorder");
  }

  lost() {
    debugPrint("Client Lost");
  }

  reset() {
    debugPrint("Client Reset");
  }

  GameState getGameState() {
    return gameState;
  }

  //For testing UI
  GameState getFakeGameState() {
    GameState gs = GameState(initTime: 180, increment: 0, players: [
      Player(name: "Deven", ip: '0.0.0.0'),
      Player(name: "Robert", ip: '0.0.0.0'),
      Player(name: "Aaron", ip: '0.0.0.0'),
      Player(name: "Waldo", ip: '0.0.0.0'),
      /*Player("Deven", "1", PlayerStatus.first, 180),
          Player("Robert", "1", PlayerStatus.notTurn, 180),
          Player("Aaron", "1", PlayerStatus.notTurn, 180),
          Player("Waldo", "1", PlayerStatus.notTurn, 180),*/
    ]);
    gs.players[0].status = PlayerStatus.first;
    for (Player p in gs.players) {
      p.time = 180;
    }
    return gs;
  }
}
