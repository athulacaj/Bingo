import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'gameCompProvider.dart';
import 'gameUserProvider.dart';

enum GameTurn {
  user,
  computer,
}

class GameControllerProvider extends ChangeNotifier {
  int computerPoint = 0;
  int userPoint = 0;
  bool isUserTurn = randomTurn();
  bool isGameFinished = false;
  void shiftTurn() {
    isUserTurn = !isUserTurn;
    // notifyListeners();
  }

  void setGameFinished() {
    isGameFinished = true;
    notifyListeners();
  }

  void setPoints(int u, int c) {
    userPoint = u;
    computerPoint = c;
    notifyListeners();
  }

  void reset() {
    isUserTurn = randomTurn();
    computerPoint = 0;
    userPoint = 0;
    isGameFinished = false;
    notifyListeners();
  }
}

bool randomTurn() {
  var random = new Random();
  int r = random.nextInt(10);
  return r % 2 == 0;
}
