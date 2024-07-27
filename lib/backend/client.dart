import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fourchess/backend/clientconnection.dart';
import 'package:fourchess/backend/connection.dart';
import 'package:fourchess/util/packet.dart';
import '../util/player.dart';
import '../util/gamestate.dart';
import 'package:uuid/uuid.dart';

class Client with ChangeNotifier {
  final int port = 38383;
  String userid = const Uuid().v4();
  late String ip;
  String roomCode;
  GameState gameState = GameState();
  late ClientConnection connection;

  Client({required String name, required String this.roomCode}) {
    Player player = Player(userid: userid, name: name, ip: "");
    gameState.addPlayer(player);

    getHostIp(roomCode).then((ip) {
      ClientConnection.initialize(ip, port, onConnection).then((c) {
        c.addEvent("updateip", onUpdateIp);
        c.addEvent("updateGameState", updateGameState);
        connection = c;
      });
    });
  }

  void updateGameState(Packet packet, Connection connection) {
    gameState = packet.gameState!;
    notifyListeners();
  }

  void onConnection(Connection connection) {
    Packet packet = Packet("join", gameState, roomCode: roomCode);
    connection.send(packet);
  }

  void onUpdateIp(Packet packet, Connection connection) {
    ip = packet.newip!;
    gameState.players[0].ip = ip;
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

  start() {
    debugPrint("[DEBUG] Client Start");
    gameState.status = GameStatus.starting;
    gameState.players[0].status = PlayerStatus.first;
    notifyListeners();
    Packet packet = Packet("start", gameState);
    connection.sendPacket(packet);
  }

  startTimer() {
    debugPrint("[DEBUG] Client Start Timer");
    gameState.players[0].status = PlayerStatus.turn;
    gameState.status = GameStatus.inProgress;
    notifyListeners();
    Packet packet = Packet("startTimer", gameState);
    connection.sendPacket(packet);
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
    connection.sendPacket(packet);
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
    connection.sendPacket(packet);
  }

  reorder() {
    debugPrint("[DEBUG] Client Reorder");
    Packet packet = Packet("reorder", gameState);
    connection.sendPacket(packet);
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
    connection.sendPacket(packet);
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
    connection.sendPacket(packet);
  }

  leave() {
    debugPrint("[DEBUG] Client Leave");
    gameState.players.removeAt(getPlayerIndex());
    Packet packet = Packet("leave", gameState);
    connection.sendPacket(packet);
    stop();
  }

  endGame() {
    gameState.status = GameStatus.terminated;
    Packet packet = Packet("endGame", gameState);
    connection.sendPacket(packet);
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
    connection.close();
  }
}
