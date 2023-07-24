enum GameStatus { starting, inProgress, paused, finished }

enum PlayerStatus { won, lost, first, turn, notTurn }

class PlayerInfo {
  PlayerInfo(this.name, this.status, this.time);
  final String name;
  PlayerStatus status;
  double time;

  @override
  String toString() {
    return "(Name: $name, Status: $status, Time: $time";
  }
}
