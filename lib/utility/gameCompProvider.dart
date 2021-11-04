import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'functions/autoplay.dart';
import 'functions/findPoints.dart';
import 'gameUserProvider.dart';

// vs comptuter

enum GameLevel { Easy, Medium, Hard }

class GameComputerProvider extends ChangeNotifier {
  int recentSelected = -1;
  int points = 0;
  int tempPoints = 0;
  bool showAnimation = false;
  static int m = 7;
  List<Map> numbersList = getNumbersList(m);
  static Function? onUserClickCallback;
  static GameLevel _gameLevel = GameLevel.Easy;

  static setGameLevel(int i) {
    if (i == 0) {
      _gameLevel = GameLevel.Easy;
    } else if (i == 1) {
      _gameLevel = GameLevel.Medium;
    } else if (i == 2) {
      _gameLevel = GameLevel.Hard;
    }
  }

  void onNumberSelected(int i) {
    numbersList[i]['selected'] = true;
    recentSelected = i;
    findPoints();
    notifyListeners();
    if (points > tempPoints) {
      print("got point");
      // pointSound();
    } else {
      // clickSound();
    }
    tempPoints = points;
    onUserClickCallback!(numbersList[i]['no']);
  }

  void onOtherUserNumberSelected(int num) {
    int i = 0;
    for (Map numberData in numbersList) {
      if (numberData['no'] == num) {
        onNumberSelected(i);
        break;
      }
      i++;
    }
  }

  void reset() {
    showAnimation = false;
    numbersList = getNumbersList(m);
    points = 0;
    tempPoints = 0;
    notifyListeners();
  }

  findPoints() {
    FindPointsClass findPointsClass = FindPointsClass(m, numbersList, points);
    findPointsClass.findPoints((int p) {
      points = p;
    });
  }

  void diagonalSelector(int i, int m, int increasing, List<Map> numbersList) {
    int t = 0;
    String d = 'D';
    for (int j = i; j < increasing;) {
      if (i == 0) {
        numbersList[j]['diagonal'] = true;
        t = j;
        j = j + m + 1;
      } else {
        numbersList[j]['diagonalOp'] = true;
        t = j;
        j = j + m - 1;

        d = 'O';
      }
    }
    if (!numbersList[t].containsKey('label$d')) {
      points++;
      numbersList[t]['label$d'] = points;
    }
  }

  void play(BuildContext context) {
    AutoPlay autoPlay = AutoPlay(m, numbersList, _gameLevel);
    List probList = autoPlay.getTotalProbalityList(m, numbersList);
    // autoPlay.increaseProbabilityIfIndexSame(probList);
    List<Map> usersList =
        Provider.of<GameUserProvider>(context, listen: false).numbersList;
    List usersProbList = autoPlay.getTotalProbalityList(m, usersList);

    // if hard
    if (_gameLevel == GameLevel.Hard)
      autoPlay.compareWithUserAndSelect(probList, usersProbList);

    int result = autoPlay.findMaxProbIndex(probList);
    if (result != -1) {
      onNumberSelected(result);
    }
  }
}

List<Map> getNumbersList(int m) {
  int limit = m * m;
  List<int> tempList = [];
  List<Map> _numbersList = [];
  for (int i = 1; i <= limit; i++) {
    tempList.add(i);
  }
  print(tempList);
  // tempList = shuffle(tempList);
  for (int num in tempList) {
    _numbersList.add({
      'no': num,
      'selected': false,
      'vertical': false,
      'horizontal': false,
      'diagonal': false,
      'diagonalOp': false,
    });
  }

  return _numbersList;
}
