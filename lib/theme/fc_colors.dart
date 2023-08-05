import 'package:flutter/material.dart';

import '../player.dart';

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

  static const Color background = Color.fromRGBO(198, 221, 255, 1);
  static const Color primaryBlue = Color.fromRGBO(130, 195, 255, 1);
  static const Color primaryBlueDisabled = Color.fromRGBO(130, 195, 255, .5);
  static const Color thinBorder = Color.fromRGBO(88, 155, 255, 1);
  static const Color accentBlue = Color.fromRGBO(68, 170, 255, 1);
}
