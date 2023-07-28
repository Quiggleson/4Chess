import 'player.dart';

enum GameStatus { starting, inProgress, paused, finished }

class GameState {

  int initTime;
  List<Player> players;
  GameStatus status;

  GameState(this.initTime, this.players, this.status);

  setPlayers(List<Player> players) {
    this.players = players;
  }
}