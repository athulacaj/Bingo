import 'dart:math';

import 'package:bingo/utility/functions/webCheck.dart';
import 'package:bingo/utility/gameControllerProvider.dart';
import 'package:bingo/utility/gameUserProvider.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'customBoxPainet.dart';

class BuildBox extends StatelessWidget {
  // late Size size;
  final int t = GameUserProvider.m;
  final double padding = 50;
  final Map data;
  final int i;
  BuildBox(this.data, this.i);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isWeb = KisWeb(size);

    GameUserProvider provider =
        Provider.of<GameUserProvider>(context, listen: false);
    GlobalKey key = GlobalKey();
    return Padding(
      padding: const EdgeInsets.all(.3),
      child: InkWell(
        onTap: () {
          bool isUserTurn =
              Provider.of<GameControllerProvider>(context, listen: false)
                  .isUserTurn;

          if (data['selected'] == false && isUserTurn) {
            provider.onNumberSelected(i, true);
          }
        },
        child: Container(
          width: (size.width * .9 - padding) / (isWeb ? t * 2.3 : t),
          height: isWeb
              ? (size.height * .63 - padding) / t
              : (size.width - padding) / t,
          // color: Colors.red,
          key: key,
          // margin: EdgeInsets.all(.4),
          child: Stack(
            children: [
              CustomPaint(
                painter: MyCustomBoxPaint(
                    data: data,
                    isRecentlySelected: provider.recentSelected == i),
                child: Container(
                    width: (size.width - padding) / t - 6,
                    height: (isWeb ? size.height : size.width - 0) / t - 6,
                    alignment: Alignment.center,
                    child: Text(
                      "${data['no']}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: data['selected'] == true
                              ? Colors.black45
                              : Colors.black),
                    )),
              ),
              if (provider.recentSelected == i && provider.showAnimation)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width:
                        (isWeb ? size.width * .35 : size.width - padding) / t,
                    height:
                        (isWeb ? size.height * .7 : size.width - padding) / t,
                    child: FlareActor("assets/flare/firework.flr",
                        alignment: Alignment.center,
                        fit: BoxFit.fill,
                        animation: "Firework"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
