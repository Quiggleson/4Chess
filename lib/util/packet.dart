import 'dart:convert';

import 'package:fourchess/util/gamestate.dart';

class Packet {
  final String call;
  final GameState? gameState;
  final String? roomCode;
  final String? status;
  final String? newip;

  Packet(this.call, this.gameState, {this.roomCode, this.newip, this.status});

  Packet.fromData(List<int> data)
      : this.fromJson(
            jsonDecode(utf8.decode(data).trim()) as Map<String, dynamic>);

  Packet.fromJson(Map<String, dynamic> json)
      : call = json['call'] as String,
        gameState = json['gameState'] == null
            ? null
            : GameState.fromJson(json['gameState']),
        roomCode = json['roomCode'] as String?,
        status = json['status'] as String?,
        newip = json['newip'] as String?;

  Map<String, dynamic> toJson() => {
        'call': call,
        'gameState': gameState,
        'roomCode': roomCode,
        'status': status,
        'newip': newip,
      };
}
