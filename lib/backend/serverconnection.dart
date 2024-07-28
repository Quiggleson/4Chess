import 'dart:io';
import 'package:fourchess/backend/connection.dart';
import 'package:fourchess/util/packet.dart';

class ServerConnection {
  final List<Connection> _connections = [];
  late ServerSocket _server;
  final Map<String, Function(Packet, Connection)> _eventMap = {};
  Function(Packet, Connection)? _defaultEvent;
  Function()? _onDisconnect;
  Function()? _onReconnect;

  ServerConnection._(ServerSocket serverSocket) {
    _server = serverSocket;

    _server.listen((Socket socket) {
      Connection connection = Connection(socket);
      connection.listen(_handlePacket);
      _connections.add(connection);
    });
  }

  static Future<ServerConnection> initialize(int port) async {
    return ServerConnection._(
        await ServerSocket.bind(InternetAddress.anyIPv4, port));
  }

  void addEvent(String name, Function(Packet, Connection) onEvent) {
    _eventMap[name] = onEvent;
  }

  set addDefaultEvent(Function(Packet, Connection) onDefaultEvent) =>
      _defaultEvent = onDefaultEvent;

  set onDisconnect(Function() onDisconnect) => _onDisconnect = onDisconnect;

  set onReconnect(Function() onReconnect) => _onReconnect = onReconnect;

  void send(Packet packet) {
    for (var connection in _connections) {
      connection.send(packet);
    }
  }

  void close() {
    _server.close();
  }

  void _handlePacket(Packet packet, Connection connection) {
    if (_eventMap[packet.call] != null) {
      _eventMap[packet.call]!(packet, connection);
    } else if (_defaultEvent != null) {
      _defaultEvent!(packet, connection);
    }
  }

  void _sendHeartbeat(Packet packet, Connection connection) {
    // Reset time since last heartbeat
    send(Packet('heartbeat', null));
  }

  void _initHeartbeat() {
    // Starts a timer, that maybe once a second, will check on our heartbeat.
    // If nothing is heard after x seconds, trigger onDisconnect
    // If we are able to reconnect, trigger onReconnect.
  }
}
