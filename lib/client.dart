import 'dart:io';
import 'package:flutter/foundation.dart';

class Client {
  final String host_ip;
  final int host_port;
  Socket? server;

  Client(this.host_ip, this.host_port){

    InternetAddress addr = InternetAddress(host_ip);
    // TO DO: see if sourcePort is necessary
    Socket.connect(addr, host_port, sourceAddress: InternetAddress.anyIPv4).then((Socket server) {

      this.server = server;

      debugPrint('Client: I have connected to the server');
    }, onError: (error) {
      debugPrint('$error');
    });

  }

  // To do: implement null server checks
  sendData(Object data) {
    debugPrint('Client: Sending: $data');
    server!.write(data);

    server!.listen((event) {
      debugPrint('Client: I have received: ${String.fromCharCodes(event).trim()}');
      debugPrint('Please reconnect');
      server!.close();
    });
  }

}