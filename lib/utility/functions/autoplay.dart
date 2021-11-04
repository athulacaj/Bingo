import 'dart:math';

import 'package:bingo/utility/gameCompProvider.dart';

class AutoPlay {
  static int currentMaximumProbability = 2;
  late int m;
  late List<Map> numbersList;
  late GameLevel _gameLevel;
  AutoPlay(this.m, this.numbersList, this._gameLevel);
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
    if (_gameLevel == GameLevel.Easy) return h + v + d;
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
