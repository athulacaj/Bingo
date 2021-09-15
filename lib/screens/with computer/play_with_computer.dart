import 'package:bingo/screens/GameScreen/gameScreen.dart';
import 'package:flutter/material.dart';

class PlayWithComputer extends StatefulWidget {
  const PlayWithComputer({Key? key}) : super(key: key);

  @override
  _PlayWithComputerState createState() => _PlayWithComputerState();
}

List<String> _options = ["Easy", "Medium", "Difficult"];

class _PlayWithComputerState extends State<PlayWithComputer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (int i = 0; i < 3; i++)
          InkWell(
              onTap: () {
                _onButtonClick(i);
              },
              child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  child: Text(_options[i])))
      ])),
    );
  }

  void _onButtonClick(int i) {
    if (i == 0) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => GameScreen()));
    }
  }
}
