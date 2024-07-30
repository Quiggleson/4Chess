import 'package:fourchess/backend/connection.dart';
import 'package:fourchess/backend/serverconnection.dart';
import 'package:fourchess/util/packet.dart';

import '../util/player.dart';

import '../util/gamestate.dart';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';

class Host {
  final int port = 38383;
  late String roomCode;
  late ServerConnection server;
  GameState gameState;

  Host({required this.gameState}) {
    ServerConnection.initialize(port).then((s) {
      s.addEvent("join", _onJoinGame);
      s.addDefaultEvent = _onCall;
      server = s;
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

  bool _onJoinGame(Packet packet, Connection connection) {
    if (packet.roomCode == roomCode) {
      Player player = packet.gameState!.players[0];
      player.time = gameState.initTime.toDouble();
      gameState.addPlayer(player);
      Packet p = Packet("updateGameState", gameState, status: "200");
      server.send(p);
      return true;
    } else {
      Packet p = Packet("Error", null, status: "403");
      connection.send(p);
      return false;
    }
  }

  void _onCall(Packet packet, Connection connection) {
    debugPrint("[DEBUG] Host onCall ${packet.call}");
    gameState = packet.gameState!;
    Packet p = Packet("updateGameState", gameState, status: "200");
    server.send(p);
  }

  stop() {
    debugPrint("[DEBUG] Stopping host server");
    server.close();
  }
}
