import 'dart:async';
import 'dart:io';
import 'package:fourchess/backend/connection.dart';
import 'package:fourchess/util/packet.dart';

class ServerConnection {
  final Map<Connection, int> _connectionsHeartbeatMap = {};
  late ServerSocket _server;
  late Map<String, Function(Packet, Connection)> _eventMap;
  Function(Packet, Connection)? _defaultEvent;
  Function()? _onDisconnect;
  Function()? _onReconnect;

  final int MILLIS_TO_WAIT_FOR_CLIENT = 3000;
  final int MILLIS_BETWEEN_HEARTBEATS = 1000;

  ServerConnection._(ServerSocket serverSocket) {
    _server = serverSocket;

    _eventMap = {'heartbeat': _handleHeartbeat};

    _server.listen((Socket socket) {
      Connection connection = Connection(socket, "host");
      connection.listen(_handlePacket);
      _connectionsHeartbeatMap[connection] =
          DateTime.now().millisecondsSinceEpoch;
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
    for (var connection in _connectionsHeartbeatMap.keys) {
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

  void _initHeartbeat() {
    Timer.periodic(Duration(milliseconds: MILLIS_BETWEEN_HEARTBEATS), (_) {
      send(Packet('heartbeat', null));

      for (var connectionHeartBeat in _connectionsHeartbeatMap.entries) {
        Connection connection = connectionHeartBeat.key;
        int timeSinceLastClientHeartbeat = connectionHeartBeat.value;

        if (timeSinceLastClientHeartbeat > MILLIS_TO_WAIT_FOR_CLIENT) {
          if (_onDisconnect != null) {
            _onDisconnect!();
          }
        }
      }
    });
    // Starts a timer, that maybe once a second, will check on our heartbeat.
    // If nothing is heard after x seconds, trigger onDisconnect
    // If we are able to reconnect, trigger onReconnect.
  }

  void _handleHeartbeat(Packet packet, Connection connection) {
    if (_connectionsHeartbeatMap.containsKey(connection)) {
      _connectionsHeartbeatMap[connection] =
          DateTime.now().millisecondsSinceEpoch;
    }
  }
}

//TODO - CREATE A VERSION OF CONNECTION WITH EASILY ACCESSIBLE METADATA