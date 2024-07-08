import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../util/player.dart';
import '../util/gamestate.dart';
import 'package:uuid/uuid.dart';

class Client with ChangeNotifier {
  final int port = 46100;
  String userid = const Uuid().v4();
  late String ip;
  GameState gameState = GameState();
  late Socket socket;

  Client({required String name, required String roomCode}) {
    getHostIp(roomCode).then((ip) {
      Socket.connect(ip, 38383, sourceAddress: InternetAddress.anyIPv4).then(
          (Socket socket) {
        debugPrint('Client has connected to server');
        this.socket = socket;

        this.ip = socket.address.address.toString();
        debugPrint(
            'This is the client, looking for ip: ${socket.remoteAddress.host}');
        debugPrint('Making player $name with ip $ip');

        Player player = Player(userid: userid, name: name, ip: ip);

        gameState = GameState(players: [player]);

        join(roomCode);
      }, onError: (err) {
        debugPrint('[CONNECTION ERROR], $err');
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
    return '';

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

  int getPlayerIndex() {
    for (final (index, player) in gameState.players.indexed) {
      if (player.userid == this.userid) {
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

    debugPrint('Client sending $message');
    socket.write(message);

    // Every time host sends out data, this is where it listens
    socket.listen((List<int> data) {
      const JsonDecoder decoder = JsonDecoder();
      final String message = utf8.decode(data).trim();
      debugPrint('[DEBUG] Client Received: $message');
      List<String> messages = message.split("begin:").sublist(1);
      debugPrint(messages.toString());
      for (var m in messages) {
        debugPrint('[DEBUG] Dealing with message: $m');
        final Map<String, dynamic> obj = decoder.convert(m);
        if (obj["status"] == '200' && obj["call"] == "updateip") {
          ip = obj["newip"];
          debugPrint('New client ip: $ip');
        } else if (obj["status"] == '200') {
          update(obj["gameState"]);
        } else {
          debugPrint(obj.toString());
        }
      }
    });
  }

  update(Map<String, dynamic> gameState) {
    if (gameState != this.gameState.getJson()) {
      this.gameState.initTime = gameState["initTime"];
      this.gameState.increment = gameState["increment"];
      this.gameState.status = GameStatus.values
          .firstWhere((e) => e.toString() == gameState["status"]);
      List<Player> players = [];
      for (dynamic d in gameState["players"]) {
        players.add(Player(
            userid: d["userid"],
            ip: d["ip"],
            name: d["name"],
            status: PlayerStatus.values
                .firstWhere((e) => e.toString() == d["status"]),
            time: d["time"]));
      }
      this.gameState.players = players;
      notifyListeners(); //use notifyListeners rather than _isModified = true
    }
  }

  start() {
    debugPrint("Client Start");
    debugPrint('Just started the ip is $ip');
    gameState.status = GameStatus.starting;
    gameState.players[0].status = PlayerStatus.first;
    notifyListeners();
    socket.write('''
    {
      "call": "start",
      "gameState": $gameState
    }
    ''');
  }

  startTimer() {
    debugPrint("Client start timer");
    gameState.players[0].status = PlayerStatus.turn;
    gameState.status = GameStatus.inProgress;
    notifyListeners();
    socket.write('''
    {
      "call": "startTimer",
      "gameState": $gameState
    }
    ''');
  }

  togglePause(double timeOfCurrentPlayer) {
    debugPrint("[DEBUG] Client Pause");
    gameState.status = gameState.status == GameStatus.paused
        ? GameStatus.inProgress
        : GameStatus.paused;
    gameState.players
        .firstWhere((player) => player.status == PlayerStatus.turn)
        .time = timeOfCurrentPlayer;
    socket.write('''
    {
      "call": "togglePause",
      "gameState": $gameState
    }
    ''');
  }

  next(double time) {
    debugPrint("[DEBUG] Client Next");

    int playerIndex = getPlayerIndex();
    int nextIndex = getNextIndex(playerIndex);
    if (nextIndex == -1) {
      debugPrint('[ERROR] Next player index is -1');
      return;
    }

    if (nextIndex == playerIndex) {
      gameState.status = GameStatus.finished;
    } else {
      // Update current player
      Player player = gameState.players[playerIndex];
      player.time = time + gameState.increment;
      player.status = PlayerStatus.notTurn;

      // Update next player
      gameState.players[nextIndex].status = PlayerStatus.turn;
    }
    debugPrint('[DEBUG] gamestate after next: $gameState');

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

  lost(double time) {
    debugPrint("[DEBUG] Client Lost");
    int playerIndex = getPlayerIndex();
    Player player = gameState.players[playerIndex];
    PlayerStatus oldStatus = player.status;
    player.status = PlayerStatus.lost;
    player.time = time;
    List<Player> playersLeft = gameState.players
        .where((player) => player.status != PlayerStatus.lost)
        .toList(); // Get all players that are not lost
    if (playersLeft.length == 1) {
      // All but one player has lost, therefore game is over
      playersLeft[0].status = PlayerStatus.won;
      gameState.status = GameStatus.finished;
    } else if (oldStatus == PlayerStatus.turn) {
      // Next player only if this client lost on their turn
      int nextIndex = getNextIndex(playerIndex);
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
    gameState.status = GameStatus.starting;
    for (int i = 0; i < gameState.players.length; i++) {
      gameState.players[i].status = PlayerStatus.notTurn;
      gameState.players[i].time = gameState.initTime.toDouble();
    }
    gameState.players[0].status =
        PlayerStatus.first; // Slightly janky but works
    socket.write('''
    {
      "call": "reset",
      "gameState": $gameState
    }
    ''');
  }

  leave() {
    gameState.players.removeAt(getPlayerIndex());
    socket.write('''
    {
      "call": "leave",
      "gameState": $gameState
    }
    ''');
    stop();
  }

  endGame() {
    gameState.status = GameStatus.terminated;
    socket.write('''
    {
      "call": "endGame",
      "gameState": $gameState
    }
    ''');
  }

  GameState getGameState() {
    return gameState;
  }

  //For testing UI
  GameState getFakeGameState() {
    GameState gs = GameState(initTime: 180, increment: 0, players: [
      Player(userid: "1", name: "Deven", ip: '0.0.0.0'),
      Player(userid: "2", name: "Robert", ip: '0.0.0.0'),
      Player(userid: "3", name: "Aaron", ip: '0.0.0.0'),
      Player(userid: "4", name: "Waldo", ip: '0.0.0.0'),
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
