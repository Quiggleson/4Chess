enum PlayerStatus { won, lost, first, turn, notTurn }

class Player {
  String userid;
  String name;
  String ip;
  PlayerStatus status;
  double time;

  Player(
      {required this.userid,
      required this.name,
      required this.ip,
      this.status = PlayerStatus.notTurn,
      this.time = 0}) {
    print('Constructed Player $name');
  }

  @override
  String toString() {
    return '{"userid": "$userid","name": "$name", "time": $time, "status": "$status", "ip": "$ip"}';
  }
}
