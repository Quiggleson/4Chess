enum PlayerStatus { won, lost, first, turn, notTurn }

class Player {
  String name;
  String ip;
  PlayerStatus status;
  double time;

  Player(this.name, this.ip, this.status, this.time) {
    print('oi');
  }
}
