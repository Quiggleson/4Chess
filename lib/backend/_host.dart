import 'dart:convert';
import 'package:fourchess/screens/game.dart';
import 'package:fourchess/util/packet.dart';

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
      final String message = utf8.decode(data).trim();
      final Map<String, dynamic> packetMap =
          jsonDecode(message) as Map<String, dynamic>;
      final packet = Packet.fromJson(packetMap);

      if (packet.call == "join") {
        onJoinGame(socket, packet);
      } else {
        gameState = packet.gameState!;
        onCall(packet.call);
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

  bool onJoinGame(Socket socket, Packet packet) {
    if (packet.roomCode == roomCode) {
      String newip = socket.remoteAddress.address.toString();
      Player player = packet.gameState!.players[0];
      player.ip = socket.remoteAddress.address.toString();
      player.time = gameState.initTime.toDouble();
      gameState.addPlayer(player);
      Packet p = Packet("updateip", null, status: "200", newip: newip);
      socket.writeln(jsonEncode(p));
      for (Socket socket in sockets) {
        Packet p = Packet("join", gameState, status: "200");
        socket.writeln(jsonEncode(p));
      }
      return true;
    } else {
      Packet p = Packet("Error", null, status: "403");
      socket.writeln(p);
      return false;
    }
  }

  void onCall(String call) {
    debugPrint("[DEBUG] Host onCall $call");
    for (var socket in sockets) {
      Packet packet = Packet(call, gameState, status: "200");
      socket.writeln(jsonEncode(packet));
    }
  }

  stop() {
    debugPrint("[DEBUG] Stopping host server");
    server.close();
  }
}
