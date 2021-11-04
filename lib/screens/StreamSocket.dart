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
        'https://mybingoserver.herokuapp.com',
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
      stream_controller.addResponse(
          {'data': "${data['name']}?${data['message']}", 'type': 'chat'});
    });
    socket.on('startGame', (data) {
      stream_controller.addResponse({'data': "$data", 'type': 'startGame'});
    });
    socket.on('shareSortedList', (data) {
      List<Map> sortedList = List<Map>.from(data['sortedList']);
      ScoreCalculator.addUserGrid(data['name'], sortedList);
      // stream_controller.addResponse({'data': "$data", 'type': 'startGame'});
    });

    socket.on('shareSelectedNum', (data) {
      stream_controller.addResponse({'data': data, 'type': 'shareSelectedNum'});
    });

    socket.on('user-disconnected', (data) {
      print("user disconnect" + data);
      usersList.remove(data);
      stream_controller
          .addResponse({'data': "$data", 'type': 'user_disconnected'});
    });
    // socket.onDisconnect((_) => print('disconnect'));
  }

  static void sendMessage(String msg, String name) {
    socket.emit('sendMessage', {_roomCode, msg, name});
  }

  static void startGame({String? user}) {
    Random random = new Random();
    int randomNumber = random.nextInt(usersList.length);
    if (user != null) {
      socket.emit('startGame', {_roomCode, user});
    } else {
      socket.emit('startGame', {_roomCode, usersList[randomNumber]});
    }
  }

  static void shareSortedList(List<Map> sortedList) {
    socket.emit('shareSortedList', {_roomCode, _name, sortedList});
  }

  static void shareSelectedNum(int num) {
    socket.emit('shareSelectedNum', {_roomCode, _name, num});
  }

  static void dispose() {
    if (socket.connected || socket.active) {
      socket.disconnect();
      socket.destroy();
    }
    socket.dispose();
  }
}
