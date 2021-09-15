import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class StreamSocket {
  final _socketResponse = StreamController<String>();

  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}

class ControlProvider {
  Future<StreamSocket> streamSocket;
  ControlProvider(this.streamSocket);
}

//
// void connectAndListen(Future<StreamSocket?> streamSocket) async {
//   Socket socket = io('http://192.168.1.14:3000',
//       OptionBuilder().setTransports(['websocket']).build());
//
//   socket.onConnect((_) {
//     print('connect');
//     socket.emit('msg', 'test');
//   });
//
//   //When an event recieved from server, data is added to the stream
//   socket.on('event', (data) async {
//     print("event from server");
//     (await streamSocket)!.addResponse;
//   });
//   socket.onDisconnect((_) => print('disconnect'));
// }
void connectAndListen(StreamController<String> controller) {
  Socket socket = io(
      'http://192.168.1.14:3000',
      OptionBuilder()
          .setTransports(['websocket']) // for Flutter or Dart VM
          .disableAutoConnect() // disable auto-connection
          .build());
  socket.connect();
  socket.onConnect((_) {
    print('connect');
    socket.emit('msg', 'test');
  });

  //When an event recieved from server, data is added to the stream
  socket.on('board_content', (data) {
    print("from server");
    controller.add("$data");
  });
  socket.onDisconnect((_) => print('disconnect'));
}
