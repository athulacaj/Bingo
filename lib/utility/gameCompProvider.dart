import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'gameUserProvider.dart';

// vs comptuter

class GameComputerProvider extends ChangeNotifier {
  int recentSelected = -1;
  int points = 0;
  int tempPoints = 0;
  bool showAnimation = false;
  static int m = 7;
  List<Map> numbersList = getNumbersList(m);
  static Function? onUserClickCallback;

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
    AutoPlay autoPlay = AutoPlay(m, numbersList);
    List probList = autoPlay.getTotalProbalityList(m, numbersList);
    // autoPlay.increaseProbabilityIfIndexSame(probList);
    List<Map> usersList =
        Provider.of<GameUserProvider>(context, listen: false).numbersList;
    List usersProbList = autoPlay.getTotalProbalityList(m, usersList);

    // if hard
    autoPlay.compareWithUserAndSelect(probList, usersProbList);

    int result = autoPlay.findMaxProbIndex(probList);
    if (result != -1) {
      onNumberSelected(result);
    }
  }
}

class AutoPlay {
  static int currentMaximumProbability = 2;
  late int m;
  late List<Map> numbersList;
  AutoPlay(this.m, this.numbersList);
  int findMaxProbIndex(List probList) {
    if (probList.isEmpty) {
      return -1;
    }
    Map resultProb = probList[0];
    for (Map data in probList) {
      if (data['prob'] > resultProb['prob']) {
        resultProb = data;
      }
    }
    print("result is $resultProb");
    return resultProb['index'];
  }

  List getTotalProbalityList(int m, List<Map> numbersList) {
    List d = playDiagonal(m, numbersList);
    List h = playHorizontal(m, numbersList);
    List v = playVertical(m, numbersList);
    return d + h + v;
  }

  void compareWithUserAndSelect(List probList, List usersProbList) {
    for (Map usersData in usersProbList) {
      if (usersData['prob'] >= 6) {
        // index in computer where user like to click
        int comProbIndex = findComProbListIndexByNo(probList, usersData['no']);
        int comIndex = probList[comProbIndex]['index'];
        if (comProbIndex != -1) {
          probList[comProbIndex]['prob']--;
          // get surroundings index where user like to click
          List sList = getSurroundings(comIndex);
          print(
              "user like ${usersData['no']} to be selected remove the index from comp ${probList[comProbIndex]}");
          print("surrounding list $sList");
          for (int surroundingIndex in sList) {
            int surrondingNumber = numbersList[surroundingIndex]['no'];
            // print("surrondingNumber $surrondingNumber");

            int sIndexInProbList =
                findComProbListIndexByNo(probList, surrondingNumber);
            // print("sIndexInProbList $sIndexInProbList");
            if (sIndexInProbList != -1) {
              probList[sIndexInProbList]['prob']++;
            }
          }
          print("finished");
        }
      }
    }
    // currentMaximumProbability = 3;
  }

  List getSurroundings(int i) {
    print("m is  $m and index is $i");
    // horizontal limits
    List sList = [];
    if (i % m == 0) {
      //left
      sList.add(i + 1);
    } else if ((i + 1) % m == 0) {
      //right\
      sList.add(i - 1);
    } else {
      sList.add(i + 1);
      sList.add(i - 1);
    }
    // vertical
    if ((i / m).floor() == 0) {
      //top
      sList.add(i + m);
    } else if ((i / m).floor() == m - 1) {
      // bottom
      sList.add(i - m);
    } else {
      sList.add(i + m);
      sList.add(i - m);
    }
    return sList;
  }

  int findComProbListIndexByNo(List probList, int number) {
    for (int i = 0; i < probList.length; i++) {
      if (probList[i]['no'] == number) {
        return i;
      }
    }
    return -1;
  }

  void increaseProbabilityIfIndexSame(List probList) {
    for (int i = 0; i < probList.length; i++) {
      int currentIndex = probList[i]['index'];
      for (int j = i + 1; j < probList.length; j++) {
        if (currentIndex == probList[j]['index'] &&
            probList[i]['prob'] <= probList[j]['prob']) {
          probList[i]['prob']++;
        }
      }
    }
  }

  List playDiagonal(int m, List<Map> numbersList) {
    // diagonal looping
    int toReturn = -1;
    List result = [];
    for (int i = 0; i < m;) {
      int increasing = numbersList.length - i;
      int prob = 0;
      List unselectedList = [];
      for (int j = i; j < increasing;) {
        if (numbersList[j]['selected'] == false) {
          toReturn = j;
          unselectedList.add(j);

          // break;
        } else {
          prob += 2;
        }
        if (i == 0) {
          j = j + m + 1;
        } else {
          j = j + m - 1;
        }
      }
      i = i + m - 1;
      if (toReturn != -1) {
        for (int num in unselectedList) {
          if (currentMaximumProbability < prob) {
            currentMaximumProbability = prob;
          }
          result
              .add({'prob': prob, 'index': num, "no": numbersList[num]['no']});
        }
      }
    }
    print(result);
    return result;
  }

  List playHorizontal(int m, List<Map> numbersList) {
    int toReturn = -1;
    List result = [];
    // horizontal looping
    int multiplier = (m - 1) * m;
    for (int i = 0; i <= multiplier;) {
      // horizontal looping  starts
      int prob = 0;
      List unselectedList = [];
      for (int j = i; j < i + m; j++) {
        if (numbersList[j]['selected'] == false) {
          toReturn = j;
          unselectedList.add(j);
        } else {
          prob += 2;
        }
      }
      i = i + m;
      if (toReturn != -1) {
        for (int num in unselectedList) {
          if (currentMaximumProbability < prob) {
            currentMaximumProbability = prob;
          }
          result
              .add({'prob': prob, 'index': num, "no": numbersList[num]['no']});
        }
      }
    }
    print(result);
    return result;
  }

  List playVertical(int m, List<Map> numbersList) {
    int toReturn = -1;
    List result = [];
    int multiplier = (m - 1) * m;
    for (int i = 0; i < m; i++) {
      // vertical looping  starts
      int prob = 0;
      List unselectedList = [];
      for (int j = i; j <= i + multiplier;) {
        if (numbersList[j]['selected'] == false) {
          toReturn = j;
          unselectedList.add(j);
        } else {
          prob += 2;
        }
        j = j + m;
      }
      if (toReturn != -1) {
        for (int num in unselectedList) {
          if (currentMaximumProbability < prob) {
            currentMaximumProbability = prob;
          }
          result
              .add({'prob': prob, 'index': num, "no": numbersList[num]['no']});
        }
      }
    }
    print(result);
    return result;
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
