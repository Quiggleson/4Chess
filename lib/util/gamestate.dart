import 'player.dart';

enum GameStatus { setup, starting, inProgress, paused, finished, terminated }

class GameState {
  int initTime;
  int increment;
  List<Player> players;
  GameStatus status = GameStatus.setup;

  GameState({this.initTime = 0, this.increment = 0, List<Player>? players})
      : players = players ?? [];

  setPlayers(List<Player> players) {
    this.players = players;
  }

  addPlayer(Player player) {
    players.add(player);
  }

  @override
  String toString() {
    //For debugging
    String output = "";

    /*output += "--- GameState --- ";
    output += "Initial time: $initTime\n";
    output += "Increment: $increment\n";
    output += "Game Status: $status\n";
    output += "Players:\n";
    for (Player player in players) {
      output += "$player\n";
    }*/
    output = '''
      {
        "initTime" : $initTime,
        "increment": $increment,
        "status": "$status",
        "players": $players
      }
    ''';

    return output;
  }

  Map<String, dynamic> getJson() {
    Map<String, dynamic> obj = {};
    obj.putIfAbsent("initTime", () => initTime);
    obj.putIfAbsent("increment", () => increment);
    obj.putIfAbsent("status", () => status);
    obj.putIfAbsent("players", () => players);

    return obj;
  }
}
