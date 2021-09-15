import 'dart:math';

import 'package:bingo/Colors.dart';
import 'package:bingo/utility/gameUserProvider.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'customBox.dart';

class UserIndexScreen extends StatelessWidget {
  final double sizeOFGreeting = 200;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Consumer<GameUserProvider>(builder: (context, provider, child) {
      return Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 4),
              Container(
                color: Colors.white.withOpacity(0.3),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                child: createLayout(context, provider.numbersList),
              ), // Row(
            ],
          ),
          // if (provider.showAnimation)
          //   Positioned(
          //     top: ((size.width - 40) - sizeOFGreeting) / 2,
          //     left: (size.width - sizeOFGreeting) / 2,
          //     child: Container(
          //       // width: (size.width - padding) / t,
          //       // height: (size.width - padding) / t,
          //       width: sizeOFGreeting,
          //       height: sizeOFGreeting,
          //       child: FlareActor("assets/flare/firework.flr",
          //           alignment: Alignment.center,
          //           fit: BoxFit.fill,
          //           animation: "Firework"),
          //     ),
          //   ),
        ],
      );
    });
  }
}

void findPostionOfChildBox() {}

Widget createLayout(BuildContext context, List<Map> numbersList) {
  List<Widget> columChildren = [];
  List<Widget> rowChildren = [];
  for (int i = 0; i < numbersList.length; i++) {
    Map numberData = numbersList[i];
    int m = sqrt(numbersList.length).round();
    if (i % m == 0) {
      if (i != 0) {
        columChildren.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: rowChildren,
        ));
      }

      rowChildren = [];
      rowChildren.add(
        BuildBox(numberData, i),
      );
    } else {
      rowChildren.add(
        BuildBox(numberData, i),
      );
    }
  }
  // last row
  columChildren.add(Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: rowChildren,
  ));
  return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: columChildren);
}
