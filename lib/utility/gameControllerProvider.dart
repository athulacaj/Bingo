import 'dart:math';

import 'package:bingo/utility/gameType.dart';
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
  bool isUserTurn = _randomTurn();
  bool isGameFinished = false;
  static GameType _gameType = GameType.offlineWithComp;
  void shiftTurn() {
    isUserTurn = !isUserTurn;
    // notifyListeners();
  }

  void setGameType(GameType type) {
    _gameType = type;
    isUserTurn = _randomTurn();
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
    isUserTurn = _randomTurn();
    computerPoint = 0;
    userPoint = 0;
    isGameFinished = false;
    notifyListeners();
  }

  static bool _randomTurn() {
    var random = new Random();
    int r = random.nextInt(10);
    if (_gameType == GameType.offlineWithUser) return true;
    return r % 2 == 0;
  }
}
