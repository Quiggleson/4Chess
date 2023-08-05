import 'player.dart';

enum GameStatus { starting, inProgress, paused, finished }

class GameState {
  int? initTime;
  int? increment;
  List<Player> players;
  GameStatus status;

  GameState(
      {this.initTime,
      this.increment,
      required this.players,
      required this.status});

  setPlayers(List<Player> players) {
    this.players = players;
  }
}
