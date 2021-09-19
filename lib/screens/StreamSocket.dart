import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

import 'GameScreen/scoreCalculator.dart';

// STEP1:  Stream setup
class StreamSocket {
  final _socketResponse = StreamController<Map>();

  void Function(Map) get addResponse => _socketResponse.sink.add;

  Stream<Map> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}

StreamSocket stream_controller = StreamSocket();
StreamSubscription<Map>? streamSubscription;

class SocketController {
  static late Socket socket;
  static List usersList = [];
  static late String _roomCode, _name;
  static void connectAndListen(bool admin, String roomCode, String name) {
    _name = name;
    _roomCode = roomCode;
    socket = io(
        'http://192.168.1.9:3000',
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            .build());
    socket.connect();
    socket.onConnect((_) {
      print('connect');
      socket.emit('join-room', [roomCode, name]);
      // socket.emit('msg', 'test');
    });

    //When an event received from server, data is added to the stream
// 1. join-room call server and trigger user-connected
// 2. user-connected catch by admin and emit sendUsersList
// 3. sendUsersList trigger usersList event from server and catch it from not admin users
    if (admin) {
      socket.on('user-connected', (data) {
        print("user-connected " + data);
        if (!usersList.contains(data)) usersList.add(data);
        socket.emit('sendUsersList', {roomCode, usersList});
        stream_controller
            .addResponse({'data': "$data", 'type': 'user_connected'});
      });
    } else {
      socket.on('sendUsersList', (data) {
        print('users List is $data');
        usersList = data;
        stream_controller
            .addResponse({'data': "$data", 'type': 'user_connected'});
      });
    }

    socket.on('receiveMessages', (data) {
      print("from server " + data);
      stream_controller.addResponse({'data': "$data", 'type': 'chat'});
    });
    socket.on('startGame', (data) {
      print('start GAme');
      stream_controller.addResponse({'data': "$data", 'type': 'startGame'});
    });
    socket.on('shareSortedList', (data) {
      print(data.runtimeType);
      List<Map> sortedList = List<Map>.from(data['sortedList']);
      ScoreCalculator.addUserGrid(data['name'], sortedList);
      // stream_controller.addResponse({'data': "$data", 'type': 'startGame'});
    });

    socket.on('user-disconnected', (data) {
      print("user disconnect" + data);
      usersList.remove(data);
      // controller.add("amal disconnect");
    });
    // socket.onDisconnect((_) => print('disconnect'));
  }

  static void sendMessage(String msg) {
    socket.emit('sendMessage', {_roomCode, msg});
  }

  static void startGame() {
    Random random = new Random();
    int randomNumber = random.nextInt(usersList.length);
    socket.emit('startGame', {_roomCode, usersList[randomNumber]});
  }

  static void shareSortedList(List<Map> sortedList) {
    socket.emit('shareSortedList', {_roomCode, _name, sortedList});
  }

  static void dispose() {
    socket.dispose();
  }
}
