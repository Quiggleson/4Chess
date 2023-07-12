import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:dart_ipify/dart_ipify.dart';

class Server {

  // I'm not exactly sure what the port should be but the 40000 range feels right
  Server(String ip, int port) {


    // Start the server
    ServerSocket.bind(InternetAddress.anyIPv4, port).then((ServerSocket server) {
      // Print ip if in debug mode
      final info = NetworkInfo();
      info.getWifiIP().then((ip) {
        debugPrint('getwifiip: $ip');
      });
      Ipify.ipv4().then((ip) {
        debugPrint('ipify: $ip');
      });

      // Listen
      server.listen((Socket client) {
        respond(client);
      });
    });
  }

  // Respond to the client
  respond(Socket client) {
    client.listen((List<int> data) {

      String message = String.fromCharCodes(data).trim();
      debugPrint('Received message from client: $message');

      client.write('This is a response to your message\n$message');
      client.write('Please reconnect');

      }, onError: (error) {
      debugPrint('Error listening to client: $error');
    }, onDone: () {
      debugPrint('Client disconnected');
      client.close();
    });
  }

  // Stop the server
  stopServer() {
    // Implement me
  }
}
