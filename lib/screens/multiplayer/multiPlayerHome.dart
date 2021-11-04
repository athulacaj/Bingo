import 'dart:math';

import 'package:bingo/screens/GameScreen/gameScreen.dart';
import 'package:bingo/screens/StreamSocket.dart';
import 'package:bingo/utility/functions/showToastFunction.dart';
import 'package:bingo/utility/gameType.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart';

import 'userDataSharedPref.dart';

// STEP1:  Stream setup

//STEP2: Add this function in main function in main.dart file and add incoming data to the stream

class MultiPlayerHome extends StatefulWidget {
  const MultiPlayerHome({Key? key}) : super(key: key);

  @override
  _MultiPlayerHomeState createState() => _MultiPlayerHomeState();
}

// StreamSocket streamSocket = StreamSocket();
class _MultiPlayerHomeState extends State<MultiPlayerHome> {
  // StreamController<Map> controller = StreamController<Map>();
  late TextEditingController _messageController;
  ScrollController _chatScrollController = ScrollController();
  String name = '';
  String? roomCode;
  bool? isAdmin;
  late TextEditingController _nameController;
  bool isJoinRoomClicked = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _nameController = TextEditingController();
    isJoinRoomClicked = false;
    initFunctions();
  }

  void initFunctions() async {
    isAdmin = null;
    usersList = [];
    chatsList = [];
    name = await UserData.getData();
    _nameController.text = name;
    setState(() {});
  }

  void generateRoomCode() {
    var rng = new Random();
    roomCode = (rng.nextInt(10000) + 1000).toString();
  }

  List usersList = [];
  List chatsList = [];

  void newUserConnected(bool admin, String roomCode, String name) {
    stream_controller.dispose();
    stream_controller = new StreamSocket();
    if (streamSubscription != null) {
      streamSubscription!.cancel();
      SocketController.dispose();
    } else {}
    SocketController.connectAndListen(admin, roomCode, name);

    // if (streamSubscription == null) {
    streamSubscription = stream_controller.getResponse.listen((event) {
      // if (event['type'] == 'user_connected') if (!usersList
      //     .contains(event['data'])) usersList.add(event['data']);
      //
      // print(usersList);
      usersList = SocketController.usersList;
      if (event['type'] == 'chat') chatsList.add(event['data']);
      if (event['type'] == 'startGame') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GameScreen(
                      gameType: GameType.onlineWithUSer,
                      usersList: usersList,
                      whoseTurn: event['data'],
                      myName: name,
                      isAdmin: isAdmin,
                    )));
      } else {
        if (mounted) setState(() {});
      }
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                isAdmin == null
                    ? selectionWidget()
                    : Column(
                        children: [
                          isAdmin!
                              ? Column(
                                  children: [
                                    TextField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                          hintText: "Enter Name"),
                                      onChanged: (value) {
                                        name = value;
                                      },
                                    ),
                                    SizedBox(height: 20),
                                    roomCode != null
                                        ? Row(
                                            children: [
                                              Text("room code:  $roomCode"),
                                              SizedBox(width: 15),
                                              RaisedButton(
                                                child: Text('Copy'),
                                                onPressed: () {
                                                  FlutterClipboard.copy(
                                                          roomCode!)
                                                      .then((value) {
                                                    showToast(
                                                        "Copied to Clipboard");
                                                  });
                                                },
                                              ),
                                            ],
                                          )
                                        : Container(),
                                    SizedBox(height: 20),
                                    MaterialButton(
                                      onPressed: () {
                                        if (name != '') {
                                          UserData.saveData(name);
                                          SocketController.usersList = [];
                                          usersList = [];
                                          SocketController.usersList.add(name);
                                          usersList.add(name);
                                          generateRoomCode();
                                          newUserConnected(
                                              true, roomCode!, name);
                                          setState(() {});
                                        } else {
                                          showToast("Enter a valid name");
                                        }
                                      },
                                      child: Text("Create Room"),
                                    ),
                                    SizedBox(height: 20),
                                    MaterialButton(
                                      onPressed: () {
                                        // TODO : remove this
                                        // SocketController.startGame();

                                        if (usersList.length > 1) {
                                          SocketController.startGame();
                                        } else {
                                          showToast(
                                              "minimum two users required");
                                        }
                                      },
                                      child: Text("Start Game"),
                                    )
                                  ],
                                )
                              : Column(
                                  children: [
                                    SizedBox(height: 20),
                                    TextField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                          hintText: "Enter Name"),
                                      onChanged: (value) {
                                        name = value;
                                      },
                                    ),
                                    SizedBox(height: 20),
                                    TextField(
                                      keyboardType:
                                          TextInputType.numberWithOptions(),
                                      decoration: InputDecoration(
                                          hintText: "Enter roomCode"),
                                      onChanged: (value) {
                                        roomCode = value;
                                      },
                                    ),
                                    SizedBox(height: 20),
                                    MaterialButton(
                                      onPressed: () {
                                        if (name != '' || roomCode == null) {
                                          isJoinRoomClicked = true;
                                          UserData.saveData(name);
                                          newUserConnected(
                                              false, roomCode!, name);
                                        } else {
                                          showToast(
                                              "Enter a valid name and room code");
                                        }
                                        setState(() {});
                                      },
                                      child: Text("Join Room"),
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),

                          SizedBox(height: 20),

                          usersList.length == 0
                              ? Container()
                              : SizedBox(
                                  height: size.height - 304,
                                  child: Row(
                                    children: [
                                      // users list
                                      Container(
                                        color: Colors.grey.withOpacity(.1),
                                        width: 150,
                                        height: size.height - 260,
                                        padding: EdgeInsets.all(6),
                                        child: Column(
                                          children: [
                                            Text("Connected Users"),
                                            Divider(),
                                            Expanded(
                                              child: ListView.builder(
                                                controller:
                                                    _chatScrollController,
                                                itemCount: usersList.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int i) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      color: Colors.grey
                                                          .withOpacity(.2),
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
                                        height: size.height - 260,
                                        // height: 180,
                                        padding: EdgeInsets.all(6),
                                        child: Column(
                                          children: [
                                            Text("Chats"),
                                            Divider(),
                                            Expanded(
                                              child: isJoinRoomClicked &&
                                                      usersList.length == 0
                                                  ? Container(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                          "Check connection or Check Room code"))
                                                  : ListView.builder(
                                                      itemCount:
                                                          chatsList.length,
                                                      shrinkWrap: true,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int i) {
                                                        Map extractedMsg =
                                                            userMsgExtractor(
                                                                chatsList[i]);
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: Material(
                                                            elevation: 3,
                                                            child: Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(5),
                                                              // child: Text(usersList[i] + " joined"),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                      child:
                                                                          Text(
                                                                    extractedMsg[
                                                                        'user'],
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .white60),
                                                                  )),
                                                                  SizedBox(
                                                                      height:
                                                                          10),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10),
                                                                    child: Text(
                                                                        extractedMsg[
                                                                            'msg']),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: size.width - 190 - 80,
                                                  child: TextField(
                                                    controller:
                                                        _messageController,
                                                    onSubmitted: (value) {
                                                      SocketController
                                                          .sendMessage(
                                                              value, name);
                                                      _messageController
                                                          .clear();

                                                      _scrollToEnd();
                                                    },
                                                  ),
                                                ),
                                                IconButton(
                                                    onPressed: () {
                                                      SocketController
                                                          .sendMessage(
                                                              _messageController
                                                                  .text,
                                                              name);
                                                      _messageController
                                                          .clear();

                                                      _scrollToEnd();
                                                    },
                                                    icon: Icon(Icons.send))
                                              ],
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
              ],
            ),
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
    super.dispose();

    if (streamSubscription != null) {
      // streamSubscription!.cancel();
    }
    // controller.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
    if (streamSubscription != null) streamSubscription!.cancel();
  }

  Widget selectionWidget() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < _options.length; i++)
            InkWell(
                onTap: () {
                  isAdmin = i == 0;
                  setState(() {});
                },
                child: Container(
                    alignment: Alignment.center,
                    height: 80,
                    child: Text(_options[i])))
        ]);
  }

  List<String> _options = [
    "Create Room",
    "Join Room",
  ];
}

Map userMsgExtractor(String data) {
  List spilitedList = data.split('?');
  String messge = '';
  for (int i = 1; i < spilitedList.length; i++) {
    messge = messge + spilitedList[i];
  }
  return {'user': spilitedList[0], "msg": messge};
}
