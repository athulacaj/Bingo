import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart';

import 'StreamSocket.dart';

// STEP1:  Stream setup

//STEP2: Add this function in main function in main.dart file and add incoming data to the stream

class StreamHomeScreen extends StatefulWidget {
  const StreamHomeScreen({Key? key}) : super(key: key);

  @override
  _StreamHomeScreenState createState() => _StreamHomeScreenState();
}

StreamController<String> controller = StreamController<String>();

// StreamSocket streamSocket = StreamSocket();
class _StreamHomeScreenState extends State<StreamHomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connectAndListen(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text("hoime"),
              StreamBuilder(
                stream: controller.stream,
                builder:
                    (BuildContext context, AsyncSnapshot<String>? snapshot) {
                  if (!snapshot!.hasData) {
                    return CircularProgressIndicator();
                  }
                  return Container(
                    child: Text("${snapshot.data!}"),
                  );
                },
              ),
              FlatButton(
                  onPressed: () async {
                    String d = await controller.stream.first;
                    print(d);
                  },
                  child: Text("click"))
            ],
          ),
        ),
      ),
    );
  }
}
