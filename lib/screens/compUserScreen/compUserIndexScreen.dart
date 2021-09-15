import 'dart:math';

import 'package:bingo/Colors.dart';
import 'package:bingo/utility/gameCompProvider.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'compUserCustomBox.dart';

class CompUserIndexScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<GameComputerProvider>(builder: (context, provider, child) {
      return Stack(
        children: [
          Column(
            children: [
              Container(
                color: Colors.black.withOpacity(0.05),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                child: createLayout(context, provider.numbersList),
              ), // Row(
            ],
          ),
        ],
      );
    });
  }
}

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
