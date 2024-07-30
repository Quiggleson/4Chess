import 'package:flutter/foundation.dart';
import 'package:fourchess/backend/connection.dart';
import 'package:fourchess/util/packet.dart';

class ClientConnection {
  late Connection _connection;
  late Map<String, Function(Packet)> _eventMap;
  Function(Packet)? _defaultEvent;
  Function()? _onDisconnect;
  Function()? _onReconnect;

  ClientConnection._(Connection connection) {
    _eventMap = {'heartbeat': _handleHeartbeat};
    _connection = connection;
    connection.listen(_handlePacket);
    _initHeartbeatCheck();
  }

  static Future<ClientConnection> initialize(String ip, int port,
      [Function(Connection)? onConnection]) async {
    Connection connection = await Connection.initialize(ip, port, onConnection);
    return ClientConnection._(connection);
  }

  void addEvent(String name, Function(Packet) onEvent) {
    _eventMap[name] = onEvent;
  }

  set addDefaultEvent(Function(Packet) onDefaultEvent) =>
      _defaultEvent = onDefaultEvent;

  set onDisconnect(Function() onDisconnect) => _onDisconnect = onDisconnect;

  set onReconnect(Function() onReconnect) => _onReconnect = onReconnect;

  void sendPacket(Packet packet) {
    _connection.send(packet);
  }

  void close() {
    _connection.close();
  }

  void _handlePacket(Packet packet, Connection connection) {
    if (_eventMap[packet.call] != null) {
      _eventMap[packet.call]!(packet);
    } else if (_defaultEvent != null) {
      _defaultEvent!(packet);
    }
  }

  void _handleHeartbeat(Packet packet) {
    // Reset time since last heartbeat
    _connection.send(Packet('heartbeat', null));
  }

  void _initHeartbeatCheck() {
    // Starts a timer, that maybe once a second, will check on our heartbeat.
    // If nothing is heard after x seconds, trigger onDisconnect
    // If we are able to reconnect, trigger onReconnect.
  }
}
