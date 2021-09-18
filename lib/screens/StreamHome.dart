import 'package:bingo/utility/gameType.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart';

import 'GameScreen/gameScreen.dart';
import 'StreamSocket.dart';

// STEP1:  Stream setup

//STEP2: Add this function in main function in main.dart file and add incoming data to the stream

class StreamHomeScreen extends StatefulWidget {
  const StreamHomeScreen({Key? key}) : super(key: key);

  @override
  _StreamHomeScreenState createState() => _StreamHomeScreenState();
}

// StreamSocket streamSocket = StreamSocket();
class _StreamHomeScreenState extends State<StreamHomeScreen> {
  // StreamController<Map> controller = StreamController<Map>();
  late TextEditingController _messageController;
  ScrollController _chatScrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _messageController = TextEditingController();
  }

  String roomCode = '4545';
  String name = 'Athul';
  List usersList = [];
  List chatsList = [];

  void newUserConnected(bool admin, String roomCode, String name) {
    SocketController.connectAndListen(admin, roomCode, name);
    if (streamSubscription == null) {
      streamSubscription = stream_controller.getResponse.listen((event) {
        // if (event['type'] == 'user_connected') if (!usersList
        //     .contains(event['data'])) usersList.add(event['data']);
        //
        // print(usersList);
        usersList = SocketController.usersList;
        if (event['type'] == 'chat') chatsList.add(event['data']);
        setState(() {});
        if (event['type'] == 'startGame') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GameScreen(
                        gameType: GameType.onlineWithUSer,
                        usersList: usersList,
                        whoseTurn: event['data'],
                      )));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // SizedBox(height: 20),
              Text("$roomCode"),
              SizedBox(height: 10),

              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(hintText: "Enter Name"),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: InputDecoration(hintText: "Enter roomCode"),
                onChanged: (value) {
                  roomCode = value;
                },
              ),
              MaterialButton(
                onPressed: () {
                  SocketController.usersList = [];
                  usersList = [];
                  SocketController.usersList.add(name);
                  usersList.add(name);
                  newUserConnected(true, roomCode, name);
                  setState(() {});
                },
                child: Text("Create Room"),
              ),
              MaterialButton(
                onPressed: () {
                  newUserConnected(false, roomCode, name);
                },
                child: Text("Join Room"),
              ),
              SizedBox(height: 20),
              MaterialButton(
                onPressed: () {
                  SocketController.startGame();
                },
                child: Text("Start"),
              ),

              SizedBox(height: 20),

              SizedBox(
                  height: size.height - 320,
                  child: Row(
                    children: [
                      // users list
                      Container(
                        color: Colors.grey.withOpacity(.1),
                        width: 150,
                        height: size.height - 320,
                        padding: EdgeInsets.all(6),
                        child: Column(
                          children: [
                            Text("Connected Users"),
                            Divider(),
                            Expanded(
                              child: ListView.builder(
                                controller: _chatScrollController,
                                itemCount: usersList.length,
                                itemBuilder: (BuildContext context, int i) {
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      color: Colors.grey.withOpacity(.2),
                                      // child: Text(usersList[i] + " joined"),
                                      child: Text(usersList[i]),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // messageList
                      Container(
                        color: Colors.white.withOpacity(.1),
                        width: size.width - 190,
                        height: size.height - 320,
                        // height: 180,
                        padding: EdgeInsets.all(6),
                        child: Column(
                          children: [
                            Text("Chats"),
                            Divider(),
                            Expanded(
                              child: ListView.builder(
                                itemCount: chatsList.length,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int i) {
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Material(
                                      elevation: 3,
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        // child: Text(usersList[i] + " joined"),
                                        child: Text(chatsList[i]),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            TextField(
                              controller: _messageController,
                              onSubmitted: (value) {
                                _messageController.clear();
                                SocketController.sendMessage(value);

                                _scrollToEnd();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),

              // FlatButton(
              //     onPressed: () async {
              //       SocketController.sendMessage("hi from athul");
              //     },
              //     child: Text("send"))
            ],
          ),
        ),
      ),
    );
  }

  _scrollToEnd() async {
    _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    if (streamSubscription != null) {
      // streamSubscription!.cancel();
    }
    // controller.dispose();
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    if (streamSubscription != null) streamSubscription!.cancel();
  }
}
