import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fourchess/util/packet.dart';

class Connection {
  final Socket socket;
  final String id;

  Connection(this.socket, this.id);

  static Future<Connection> initialize(String ip, int port, String id,
      [Function(Connection)? onConnect]) async {
    Socket socket =
        await Socket.connect(ip, port, sourceAddress: InternetAddress.anyIPv4)
            .then((Socket s) {
      if (onConnect != null) {
        onConnect(Connection(s, id));
      }
      return s;
    }, onError: (err) {
      debugPrint('[CONNECTION ERROR] $err');
    });

    return Connection(socket, id);
  }

  void listen(Function(Packet, Connection) onPacket) {
    socket.listen((List<int> data) {
      final String message = utf8.decode(data).trim();
      List<String> messages = message.split("\n");
      for (var m in messages) {
        final Map<String, dynamic> packetMap =
            jsonDecode(m) as Map<String, dynamic>;
        onPacket(Packet.fromJson(packetMap), Connection(socket, id));
      }
    });
  }

  void send(Packet packet) {
    socket.writeln(jsonEncode(packet));
  }

  void close() {
    socket.close();
  }
}
