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

  Player.fromJson(Map<String, dynamic> json)
      : userid = json['userid'] as String,
        name = json['name'] as String,
        ip = json['ip'] as String,
        status = PlayerStatus.values
            .firstWhere((e) => e.toString() == json['status']),
        time = json['time'] as double;

  Map<String, dynamic> toJson() => {
        'userid': userid,
        'name': name,
        'ip': ip,
        'status': status.toString(),
        'time': time,
      };

  @override
  String toString() {
    return '{"userid": "$userid","name": "$name", "time": $time, "status": "$status", "ip": "$ip"}';
  }
}
