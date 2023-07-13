import 'dart:io';
import 'package:flutter/foundation.dart';

class Client {
  final String host_ip;
  final int host_port;
  Socket? server;

  Client(this.host_ip, this.host_port){

    InternetAddress addr = InternetAddress(host_ip);
    // TO DO: see if sourcePort is necessary
    Socket.connect(addr, host_port, sourcePort: host_port).then((Socket server) {

      this.server = server;

      debugPrint('I have connected to the server');
    }, onError: (error) {
      debugPrint('$error');
    });

  }

  sendData(Object data) {
    /*Socket.connect(host_ip, host_port).then((Socket server) {
      debugPrint('Sending ' + data.toString());
      server.write(data);
    }, onError: (error) {
      debugPrint('Oi there\'s an error');
    });*/
    debugPrint('Sending $data');
    server!.write(data);
    server!.listen((event) {
      debugPrint('I have received ${String.fromCharCodes(event).trim()}');
    });
  }

}