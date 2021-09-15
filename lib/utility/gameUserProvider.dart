import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';

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

  void verticalSelector(int i, int m, int multiplier, List<Map> numbersList) {
    int j;
    for (j = i; j <= i + multiplier;) {
      numbersList[j]['vertical'] = true;
      j = j + m;
    }
    j = j - m;
    if (!numbersList[j].containsKey('labelV')) {
      points++;
      numbersList[j]['labelV'] = points;
    }
  }

  void horizontalSelector(int i, int m, int multiplier, List<Map> numbersList) {
    int j;
    for (j = i; j < i + m; j++) {
      numbersList[j]['horizontal'] = true;
    }
    j = j - 1;
    if (!numbersList[j].containsKey('labelH')) {
      points++;
      numbersList[j]['labelH'] = points;
    }
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
}

class FindPointsClass {
  late int m, multiplier, points;
  late List<Map> numbersList;

  FindPointsClass(this.m, this.numbersList, this.points)
      : multiplier = (m - 1) * m;

  void findPoints(Function callBack) {
    int m = sqrt(numbersList.length).round();
    int multiplier = (m - 1) * m;
    // vertical looping
    for (int i = 0; i < m; i++) {
      // vertical looping  starts
      bool allVselected = true;
      for (int j = i; j <= i + multiplier;) {
        if (numbersList[j]['selected'] == false) {
          allVselected = false;
          break;
        }
        j = j + m;
      }
      if (allVselected) {
        verticalSelector(i, m, multiplier, numbersList);
      }
    }
    // horizontal looping
    for (int i = 0; i <= multiplier;) {
      // horizontal looping  starts
      bool allVselected = true;
      for (int j = i; j < i + m; j++) {
        if (numbersList[j]['selected'] == false) {
          allVselected = false;
          break;
        }
      }
      if (allVselected) {
        horizontalSelector(i, m, multiplier, numbersList);
      }
      i = i + m;
    }

    // diagonal looping
    for (int i = 0; i < m;) {
      // horizontal looping  starts
      bool allVselected = true;
      int increasing = numbersList.length - i;
      for (int j = i; j < increasing;) {
        if (numbersList[j]['selected'] == false) {
          allVselected = false;
          break;
        }
        if (i == 0) {
          j = j + m + 1;
        } else {
          j = j + m - 1;
        }
      }
      if (allVselected) {
        diagonalSelector(i, m, increasing, numbersList);
      }
      i = i + m - 1;
    }
    callBack(points);
  }

  void verticalSelector(int i, int m, int multiplier, List<Map> numbersList) {
    int j;
    for (j = i; j <= i + multiplier;) {
      numbersList[j]['vertical'] = true;
      j = j + m;
    }
    j = j - m;
    if (!numbersList[j].containsKey('labelV')) {
      points++;
      numbersList[j]['labelV'] = points;
    }
  }

  void horizontalSelector(int i, int m, int multiplier, List<Map> numbersList) {
    int j;
    for (j = i; j < i + m; j++) {
      numbersList[j]['horizontal'] = true;
    }
    j = j - 1;
    if (!numbersList[j].containsKey('labelH')) {
      points++;
      numbersList[j]['labelH'] = points;
    }
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
