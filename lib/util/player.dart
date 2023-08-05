enum PlayerStatus { won, lost, first, turn, notTurn }

class Player {
  String name;
  String ip;
  PlayerStatus status;
  double time;

  Player(this.name, this.ip, this.status, this.time) {
    print('Constructed Player $name');
  }

  @override
  String toString() {
    return "{Name: $name, Time: $time, Status: $status, Ip: $ip}";
  }
}
