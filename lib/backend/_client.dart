import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fourchess/util/packet.dart';
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
        socket.close();
        return ipAddress;
      } catch (e) {
        debugPrint('Failed to connect to $ipAddress: $e');
      }
    }
    return '';
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

  join(String roomCode) {
    Packet packet = Packet("join", gameState, roomCode: roomCode);
    socket.writeln(jsonEncode(packet));

    // Every time host sends out data, this is where it listens
    socket.listen((List<int> data) {
      final String message = utf8.decode(data).trim();
      List<String> messages = message.split("\n");

      for (var m in messages) {
        debugPrint('[DEBUG] Dealing with message: $m');

        final Map<String, dynamic> packetMap =
            jsonDecode(m) as Map<String, dynamic>;
        Packet packet = Packet.fromJson(packetMap);

        if (packet.status == '200' && packet.newip != null) {
          ip = packet.newip!;
          debugPrint('[DEBUG] New client ip: $ip');
        } else if (packet.status == '200' && packet.gameState != null) {
          gameState = packet.gameState!;
          notifyListeners();
        } else {
          debugPrint("[DEBUG] $packet");
        }
      }
    });
  }

  start() {
    debugPrint("[DEBUG] Client Start");
    gameState.status = GameStatus.starting;
    gameState.players[0].status = PlayerStatus.first;
    notifyListeners();
    Packet packet = Packet("start", gameState);
    socket.writeln(jsonEncode(packet));
  }

  startTimer() {
    debugPrint("[DEBUG] Client Start Timer");
    gameState.players[0].status = PlayerStatus.turn;
    gameState.status = GameStatus.inProgress;
    notifyListeners();
    Packet packet = Packet("startTimer", gameState);
    socket.writeln(jsonEncode(packet));
  }

  togglePause(double timeOfCurrentPlayer) {
    debugPrint("[DEBUG] Client Pause");
    gameState.status = gameState.status == GameStatus.paused
        ? GameStatus.inProgress
        : GameStatus.paused;
    gameState.players
        .firstWhere((player) => player.status == PlayerStatus.turn)
        .time = timeOfCurrentPlayer;
    Packet packet = Packet("togglePause", gameState);
    socket.writeln(jsonEncode(packet));
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
    Packet packet = Packet("next", gameState);
    socket.writeln(jsonEncode(packet));
  }

  reorder() {
    debugPrint("[DEBUG] Client Reorder");
    Packet packet = Packet("reorder", gameState);
    socket.writeln(jsonEncode(packet));
  }

  lost(double time) {
    debugPrint("[DEBUG] Client Lost");
    Player player = gameState.players[getPlayerIndex()];
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
      int nextIndex = getNextIndex(getPlayerIndex());
      gameState.players[nextIndex].status = PlayerStatus.turn;
    }
    Packet packet = Packet("lost", gameState);
    socket.writeln(jsonEncode(packet));
  }

  reset() {
    debugPrint("[DEBUG] Client Reset");
    gameState.status = GameStatus.starting;
    for (int i = 0; i < gameState.players.length; i++) {
      gameState.players[i].status = PlayerStatus.notTurn;
      gameState.players[i].time = gameState.initTime.toDouble();
    }
    gameState.players[0].status =
        PlayerStatus.first; // Slightly janky but works
    Packet packet = Packet("reset", gameState);
    socket.writeln(jsonEncode(packet));
  }

  leave() {
    debugPrint("[DEBUG] Client Leave");
    gameState.players.removeAt(getPlayerIndex());
    Packet packet = Packet("leave", gameState);
    socket.writeln(jsonEncode(packet));
    stop();
  }

  endGame() {
    gameState.status = GameStatus.terminated;
    Packet packet = Packet("endGame", gameState);
    socket.writeln(jsonEncode(packet));
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
