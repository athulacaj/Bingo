import 'dart:math';

import 'package:bingo/utility/functions/webCheck.dart';
import 'package:bingo/utility/gameCompProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'compUsercustomBoxPainet.dart';

class BuildBox extends StatelessWidget {
  // late Size size;
  final int t = GameComputerProvider.m + 1;
  final Map data;
  final int i;
  BuildBox(this.data, this.i);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    GameComputerProvider provider =
        Provider.of<GameComputerProvider>(context, listen: false);
    GlobalKey key = GlobalKey();
    bool isWeb = KisWeb(size);
    double padding = isWeb ? 50 : 16;
    return Padding(
      padding: const EdgeInsets.all(.3),
      child: InkWell(
        key: key,
        onTapDown: (details) {
          // print(details.globalPosition);
          // if (data['selected'] == false) {
          //   provider.onNumberSelected(i);
          // }
        },
        onTap: () {
          // RenderObject? box = key.currentContext!.findRenderObject() as RenderBox;
          // print(box.c.toString());
          // Offset position =
          //     localToGlobal(Offset.zero, box); //this is global position
          // double y = position.dy; // if (data['selected'] == false) {
          //   provider.onNumberSelected(i);
          // }
        },
        child: Container(
          width: (isWeb ? size.width / 2.1 : size.width - padding) / t - 6,
          height: isWeb
              ? (size.height * .68 - padding) / t
              : (size.height - size.width) / (t + 2),
          // margin: EdgeInsets.all(.4),
          child: CustomPaint(
            painter: MyCustomBoxPaint(
                data: data, isRecentlySelected: provider.recentSelected == i),
            child: Container(
                width: (isWeb ? size.width / 2 : size.width - padding) / t,
                height: isWeb ? (size.height) : (size.height - size.width) / t,
                alignment: Alignment.center,
                child: Text(
                  "${data['no']}",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13),
                )),
          ),
        ),
      ),
    );
  }
}
