import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';

import 'functions/findPoints.dart';

class GameUserProvider extends ChangeNotifier {
  int recentSelected = -1;
  int points = 0;
  int tempPoints = 0;
  bool showAnimation = false;
  static int m = 7;
  static Function? onUserClickCallback;
  List<Map> numbersList = getNumbersList(m);
  AssetsAudioPlayer player = AssetsAudioPlayer.newPlayer();
  void onNumberSelected(int i, bool fromThisUserClicked) {
    numbersList[i]['selected'] = true;
    recentSelected = i;
    findPoints();
    notifyListeners();
    if (points > tempPoints) {
      print("got point");
      setShowAnimation();
      pointSound();
    } else {
      clickSound(player);
    }
    tempPoints = points;
    if (fromThisUserClicked) {
      onUserClickCallback!(numbersList[i]['no']);
    }
  }

  void onOtherUserNumberSelected(int num) {
    int i = 0;
    for (Map numberData in numbersList) {
      if (numberData['no'] == num) {
        onNumberSelected(i, false);
        break;
      }
      i++;
    }
  }

  void setShowAnimation() async {
    showAnimation = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 1000));
    showAnimation = false;
    notifyListeners();
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
}

void clickSound(AssetsAudioPlayer player) {
  player.stop();
  player.open(
    Audio("assets/audios/click.wav"),
    autoStart: true,
    volume: 1,
    // showNotification: true,
  );
}

void pointSound() {
  AssetsAudioPlayer.newPlayer().open(
    Audio("assets/audios/point.wav"),
    autoStart: true,
    volume: 1,
    // showNotification: true,
  );
}

List<Map> getNumbersList(int m) {
  int limit = m * m;
  List<int> tempList = [];
  List<Map> _numbersList = [];
  for (int i = 1; i <= limit; i++) {
    tempList.add(i);
  }
  print(tempList);
  tempList = shuffle(tempList);
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

List<int> shuffle(List<int> items) {
  var random = new Random();

  // Go through all elements.
  for (var i = items.length - 1; i > 0; i--) {
    // Pick a pseudorandom number according to the list length
    var n = random.nextInt(i + 1);

    var temp = items[i];
    items[i] = items[n];
    items[n] = temp;
  }

  return items;
}
