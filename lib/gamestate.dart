import 'player.dart';

enum GameStatus { setup, starting, inProgress, paused, finished }

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

  @override
  String toString() {
    //For debugging
    String output = "";

    output += "--- GameState --- ";
    output += "Initial time: $initTime\n";
    output += "Increment: $increment\n";
    output += "Game Status: $status\n";
    output += "Players:\n";
    for (Player player in players) {
      output += "$player\n";
    }

    return output;
  }
}
