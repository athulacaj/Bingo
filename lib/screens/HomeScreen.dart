import 'package:bingo/utility/gameType.dart';
import 'package:flutter/material.dart';

import 'GameScreen/gameScreen.dart';
import 'multiplayer/multiPlayerHome.dart';
import 'with computer/play_with_computer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

List<String> _options = [
  "Play With Computer",
  "Play Offline With Friends",
  "Play Online With Friends"
];

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            for (int i = 0; i < _options.length; i++)
              InkWell(
                  onTap: () {
                    _onButtonClick(i);
                  },
                  child: Container(
                      alignment: Alignment.center,
                      height: 80,
                      child: Text(_options[i])))
          ])),
    );
  }

  void _onButtonClick(int i) {
    if (i == 0) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PlayWithComputer()));
    } else if (i == 1) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  GameScreen(gameType: GameType.offlineWithUser)));
    } else if (i == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MultiPlayerHome()));
    }
  }
}
