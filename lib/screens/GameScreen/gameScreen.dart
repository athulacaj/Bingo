import 'dart:math';
import 'package:bingo/Colors.dart';
import 'package:bingo/screens/compUserScreen/compUserIndexScreen.dart';
import 'package:bingo/screens/userScreen/userIndexScreen.dart';
import 'package:bingo/utility/functions/webCheck.dart';
import 'package:bingo/utility/gameControllerProvider.dart';
import 'package:bingo/utility/gameCompProvider.dart';
import 'package:bingo/utility/gameType.dart';
import 'package:bingo/utility/gameUserProvider.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  final GameType gameType;
  const GameScreen({required this.gameType});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  ScrollController _scrollController = ScrollController();
  bool _showWinBanner = true;
  late Size size;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _showWinBanner = true;
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    setGameDetails();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    size = MediaQuery.of(context).size;

    WidgetsBinding.instance!
        .addPostFrameCallback((_) => changeBackground(size));
  }

  void setGameDetails() {
    Provider.of<GameControllerProvider>(context, listen: false)
        .setGameType(widget.gameType);

    GameUserProvider.m = 5;
    GameComputerProvider.m = 5;

    if (!Provider.of<GameControllerProvider>(context, listen: false).isUserTurn)
      playComputer();

    GameUserProvider.onUserClickCallback = (int num) {
      print(num);
      Provider.of<GameComputerProvider>(context, listen: false)
          .onOtherUserNumberSelected(num);
      pointsController(() {
        playComputer();
      });
    };
    GameComputerProvider.onUserClickCallback = (int num) {
      Provider.of<GameUserProvider>(context, listen: false)
          .onOtherUserNumberSelected(num);
      pointsController(() {
        shiftTurn();
      });
    };
  }

  void playComputer() async {
    // play computer if gameType is  offline with computer
    if (widget.gameType == GameType.offlineWithComp) {
      await Future.delayed(Duration(milliseconds: 1300));
      Provider.of<GameComputerProvider>(context, listen: false).play(context);
    }
  }

  void shiftTurn() {
    if (widget.gameType == GameType.offlineWithComp) {
      Provider.of<GameControllerProvider>(context, listen: false).shiftTurn();
    }
  }

  void pointsController(Function afterGameFinishFunction) {
    int u = Provider.of<GameUserProvider>(context, listen: false).points;
    int c = Provider.of<GameComputerProvider>(context, listen: false).points;
    Provider.of<GameControllerProvider>(context, listen: false).setPoints(u, c);
    if (!checkGameFinished(u, c)) afterGameFinishFunction();
  }

  String result = '';
  bool checkGameFinished(int usr, int com) {
    if (usr >= 5 || com >= 5) {
      if (usr >= 5 && com >= 5) {
        result = "Draw";
      } else if (usr >= 5) {
        result = "You Won";
      } else {
        result = "Computer Won";
      }
      Provider.of<GameControllerProvider>(context, listen: false)
          .setGameFinished();
      return true;
    }
    return false;
  }

  void resetGame() {
    Provider.of<GameUserProvider>(context, listen: false).reset();
    Provider.of<GameComputerProvider>(context, listen: false).reset();
    Provider.of<GameControllerProvider>(context, listen: false).reset();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    bool isWeb = KisWeb(size);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: size.height,
              width: size.width,
              child: ListView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                children: [
                  Image.asset(
                    "assets/images/scenery3.png",
                    height: size.height - 16,
                    // width: size.width * 2,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            Container(
                color: Colors.black.withOpacity(.94),
                width: size.width,
                height: size.height),
            // Positioned(
            //   top: 0,
            //   left: 0,
            //   child: Container(
            //     height: size.height,
            //     width: size.width * 1.6,
            //     child: FlareActor("assets/flare/snow.flr",
            //         alignment: Alignment.center,
            //         fit: BoxFit.cover,
            //         animation: "idle"),
            //   ),
            // ),
            Consumer<GameControllerProvider>(
                builder: (context, gameControllerProvider, child) {
              bool isUserTurn = gameControllerProvider.isUserTurn;
              return Positioned(
                top: 0,
                left: 0,
                child: Container(
                  color: topColor,
                  width: size.width,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      userBox("Me", isUserTurn ? "Me" : '',
                          gameControllerProvider.userPoint),
                      Spacer(),
                      userBox("Comp", !isUserTurn ? "Comp" : '',
                          gameControllerProvider.computerPoint),
                    ],
                  ),
                ),
              );
            }),
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Colors.black.withOpacity(0.05),
                    Colors.white.withOpacity(.1)
                  ])),
            ),
            // if the width > height app crash
            widget.gameType != GameType.offlineWithUser
                ? Positioned(
                    top: isWeb ? (size.height * .2) + 35 : 50,
                    right: 0,
                    child: SizedBox(
                        height: isWeb
                            ? size.height
                            : size.height - (size.width - 40) - 50,
                        width: isWeb ? size.width / 2 : size.width,
                        child: CompUserIndexScreen()),
                  )
                : Container(),
            Positioned(
              left: widget.gameType != GameType.offlineWithUser
                  ? 0
                  : isWeb
                      ? size.width / 4
                      : 0,
              top: isWeb || widget.gameType == GameType.offlineWithUser
                  ? size.height * .2
                  : size.height - (size.width - 40) - 10,
              child: SizedBox(
                // height: (size.width - 40),
                width: isWeb ? size.width / 2 : size.width,
                child: UserIndexScreen(),
              ),
            ),
            // Positioned(
            //     bottom: 0,
            //     left: 10,
            //     child: FlatButton(
            //         child: Text('Replay'),
            //         onPressed: () {
            //           resetGame();
            //           setGameDetails();
            //         })),
            Positioned(
              top: isWeb ? size.height * .6 : size.height / 2,
              left: isWeb ? size.width / 4 : 0,
              child: Container(
                  height: size.height / 2,
                  padding: EdgeInsets.all(4),
                  alignment: Alignment.center,
                  child: new RotatedBox(
                      quarterTurns: isWeb ? 0 : 3,
                      child: new Text(
                        "You",
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: 16),
                      ))),
            ),
            widget.gameType != GameType.offlineWithUser
                ? Positioned(
                    top: isWeb ? size.height * .6 : 10,
                    left: isWeb ? size.width / 1.3 : 0,
                    child: Container(
                        height: isWeb
                            ? size.height / 2
                            : size.height - (size.width - 40) - 90,
                        padding: EdgeInsets.all(4),
                        alignment: Alignment.center,
                        child: new RotatedBox(
                            quarterTurns: isWeb ? 0 : 3,
                            child: new Text(
                              "Computer",
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: 16),
                            ))),
                  )
                : Container(),
            Consumer<GameControllerProvider>(
                builder: (context, gameControllerProvider, child) {
              return gameControllerProvider.isGameFinished
                  ? Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        color: Colors.black.withOpacity(.3),
                        width: size.width,
                        height: size.height,
                        child: Column(
                          children: [
                            Spacer(),
                            _showWinBanner
                                ? Container(
                                    height: 110,
                                    width: size.width,
                                    color: Colors.white,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              _showWinBanner = false;
                                              setState(() {});
                                            },
                                            icon: Icon(Icons.close)),
                                        Container(
                                          child: Text(
                                            "Result : $result",
                                            style: TextStyle(
                                                color: topColor,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          padding: EdgeInsets.all(18),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            Spacer(),
                            FlatButton(
                                color: Colors.orange,
                                child: Text('   Replay   '),
                                onPressed: () {
                                  Provider.of<GameUserProvider>(context,
                                          listen: false)
                                      .reset();
                                  Provider.of<GameComputerProvider>(context,
                                          listen: false)
                                      .reset();
                                  Provider.of<GameControllerProvider>(context,
                                          listen: false)
                                      .reset();
                                  setGameDetails();
                                }),
                            SizedBox(height: 50),
                          ],
                        ),
                      ))
                  : Container();
            }),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }

  Random random = new Random();

  void changeBackground(Size size) {
    double randomNumber =
        random.nextInt(size.width.toInt()) + .1; // from 10 upto 99 included
    _scrollController.animateTo(randomNumber,
        duration: Duration(milliseconds: 1000), curve: Curves.linear);
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    resetGame();
    super.deactivate();
  }
}

Widget userBox(String name, String turn, int points) {
  String bingo = "BINGO             ";
  return AnimatedContainer(
    padding: EdgeInsets.symmetric(horizontal: 6),
    duration: Duration(milliseconds: 500),
    color: name == turn ? Colors.orangeAccent : null,
    child: Column(children: [
      Row(
        children: [
          Icon(
            Icons.supervised_user_circle,
            color: Colors.white,
          ),
          Text(
            bingo.substring(0, points),
            style: TextStyle(
                color: name == turn ? Colors.white : Colors.white,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
      Text("$name", style: TextStyle(color: Colors.white70))
    ]),
  );
}
