import 'package:flutter/material.dart';

import '../util/playerinfo.dart';

class FCColors {
  //Default Theme Colors

  //Player timer colors
  static const Color playerWon = Color.fromRGBO(128, 125, 255, 1);
  static const Color playerLost = Color.fromRGBO(255, 110, 110, 1);
  static const Color playerFirst = Color.fromRGBO(160, 255, 169, 1);
  static const Color playerTurn = Color.fromRGBO(68, 170, 255, 1);
  static const Color playerNotTurn = Color.fromRGBO(130, 195, 255, 1);

  static const Map fromPlayerStatus = <PlayerStatus, Color>{
    PlayerStatus.won: FCColors.playerWon,
    PlayerStatus.lost: FCColors.playerLost,
    PlayerStatus.first: FCColors.playerFirst,
    PlayerStatus.turn: FCColors.playerTurn,
    PlayerStatus.notTurn: FCColors.playerNotTurn,
  };
}
