import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../util/player.dart';
import '../util/gamestate.dart';

class Client {
  final int port = 46100;
  late final String ip;
  // Flutter gets mad when this is late so throw a dummy gamestate in there
  GameState gameState = GameState();
  late Socket socket;
  bool _isModified = false;

  Client({required String name, required String roomCode}) {
    // Connect to host - populate ip, gameState, and socket
    getHostIp(roomCode).then((ip) {
      debugPrint('About to reconnect');
      Socket.connect(ip, 38383, sourceAddress: InternetAddress.anyIPv4).then(
          (Socket socket) {
        debugPrint('Client has connected to server');
        this.socket = socket;

        this.ip = socket.address.address.toString();

        Player player = Player(name: name, ip: ip);

        gameState = GameState(players: [player]);

        // Join game
        join(roomCode);
      }, onError: (err) {
        debugPrint('Oi there was an error connecting, $err');
      });
    });
  }

  Future<String> getHostIp(String roomCode) async {
    int part2 = int.parse(roomCode.substring(0, 2), radix: 16);
    int part3 = int.parse(roomCode.substring(2, 4), radix: 16);
    int part4 = int.parse(roomCode.substring(4, 6), radix: 16);

    List<String> possibleIps = [
      '192.$part2.$part3.$part4',
      '10.$part2.$part3.$part4',
      '172.$part2.$part3.$part4'
    ];

    for (final ipAddress in possibleIps) {
      debugPrint('Trying ip $ipAddress');
      try {
        final socket = await Socket.connect(ipAddress, 38383,
            sourceAddress: InternetAddress.anyIPv4,
            timeout: const Duration(seconds: 1));
        debugPrint('We found a good address');
        socket.close();
        return ipAddress;
      } catch (e) {
        debugPrint('Failed to connect to $ipAddress: $e');
      }
    }
    return ''; // Return null if no connections were successful.

    // Future<String>? ans;
    // // Want to cycle through each possibleIp
    // // wait for Socket.connect, if error continue, otherwise return
    // possibleIps.forEach((ip) async {
    //   ans = await Socket.connect(ip, 38383, sourceAddress: InternetAddress.anyIPv4)
    //       .then((Socket socket) {
    //     debugPrint('Tried and succeeded ip $ip');
    //     socket.close();
    //     //return ip;
    //   }, onError: (err) {
    //     debugPrint('Tried and failed IP $ip \n$err');
    //   });
    // });
    // String real_ans = await ans ?? '';
    // return real_ans;
    // // debugPrint('Failed to get ip');
    // // return '0.0.0.0';
  }

  bool isDirty() {
    // debugPrint('Checking isdirty. _ismodified: $_isModified');
    if (_isModified) {
      _isModified = false;
      return true;
    }
    return false;
  }

  int getPlayerIndex() {
    for (final (index, player) in gameState.players.indexed) {
      debugPrint('getplayerindex gamestate: $gameState');
      debugPrint('myip: $ip and playerip: ${player.ip}');
      if (player.ip == ip) {
        return index;
      }
    }
    return -1;
  }

  int getNextIndex(int initial) {
    for (int i = 1; i <= gameState.players.length; i++) {
      int current = (initial + i) % gameState.players.length;
      if (gameState.players[current].status == PlayerStatus.notTurn ||
          current == initial) {
        return current;
      }
    }
    return -1;
  }

  // Send player data
  join(String roomCode) {
    String message = '''
          {
            "call": "join",
            "roomCode": "$roomCode",
            "gameState" : $gameState
          }
        ''';

    debugPrint('Sending $message');
    socket.write(message);

    // Listen for response - everytime host sends out, this is where it listens
    socket.listen((List<int> data) {
      debugPrint('Im listening');
      const JsonDecoder decoder = JsonDecoder();
      final String message = utf8.decode(data).trim();
      debugPrint('Received: $message');
      final Map<String, dynamic> obj = decoder.convert(message);
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
      _isModified = true;
    }
  }

  start() {
    debugPrint("Client Start");
    debugPrint('Just started the ip is $ip');
    gameState.status = GameStatus.starting;
    gameState.players[0].status = PlayerStatus.first;
    _isModified = true;
    socket.write('''
    {
      "call": "start",
      "gameState": $gameState
    }
    ''');
  }

  pause() {
    debugPrint("Client Pause");
    gameState.status = GameStatus.paused;
    socket.write('''
    {
      "call": "start",
      "gameState": $gameState
    }
    ''');
  }

  next(double time) {
    debugPrint("Client Next");

    int playerIndex = getPlayerIndex();
    int nextIndex = getNextIndex(playerIndex);

    if (nextIndex == -1) {
      debugPrint('Something horribly wrong has happened');
      return;
    }

    if (nextIndex == playerIndex) {
      gameState.status = GameStatus.finished;
    } else {
      // Update current player
      Player player = gameState.players[playerIndex];
      player.time = time;
      player.status = PlayerStatus.notTurn;

      // Update next player
      gameState.players[nextIndex].status = PlayerStatus.turn;
    }
    debugPrint('gs after next: $gameState');

    socket.write('''
    {
      "call": "next",
      "gameState": $gameState
    }
    ''');
  }

  reorder(List<Player> players) {
    debugPrint("Client Reorder");
    debugPrint('ip is $ip');
    socket.write('''
      {
        "call": "reorder",
        "gameState": $gameState
      }
    ''');
  }

  lost() {
    debugPrint("Client Lost");
    int playerIndex = getPlayerIndex();
    int nextIndex = getNextIndex(playerIndex);
    if (nextIndex == playerIndex) {
      gameState.status = GameStatus.finished;
    } else {
      Player player = gameState.players[playerIndex];
      player.status = PlayerStatus.lost;
      gameState.players[nextIndex].status = PlayerStatus.turn;

      gameState.players[nextIndex].status = PlayerStatus.turn;
    }

    socket.write('''
    {
      "call": "next",
      "gameState": $gameState
    }
    ''');
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

  stop() {
    socket.close();
  }
}
