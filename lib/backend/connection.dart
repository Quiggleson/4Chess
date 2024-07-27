import 'dart:convert';
import 'dart:io';

import 'package:fourchess/util/packet.dart';

class Connection {
  final Socket socket;

  Connection(this.socket);

  static Future<Connection> initialize(
      String ip, int port, Function(Connection) onConnect) async {
    Socket socket =
        await Socket.connect(ip, port, sourceAddress: InternetAddress.anyIPv4)
            .then((s) => onConnect(Connection(s)));

    return Connection(socket);
  }

  void listen(Function(Packet, Connection) onPacket) {
    socket.listen((List<int> data) =>
        onPacket(Packet.fromData(data), Connection(socket)));
  }

  void send(Packet packet) {
    socket.writeln(jsonEncode(packet));
  }

  void close() {
    socket.close();
  }
}
