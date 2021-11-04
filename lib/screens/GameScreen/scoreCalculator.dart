import 'package:bingo/utility/functions/findPoints.dart';
import 'package:flutter/material.dart';

class ScoreCalculator extends ChangeNotifier {
  List _itemsSelected = [];
  List<String> usersList = [];
  static Map _userGridArrangedListData = {};
  static Map pointsData = {};
  static Map rankData = {};
  static List selectedNumbersList = [];
  static int rank = 1;
  ScoreCalculator() {
    // _itemsSelected = [];
    // _userGridArrangedListData = {};
  }

  static void initFunctions(List usersList) {
    for (String user in usersList) {
      pointsData[user] = 0;
    }
  }

  static void reset() {
    // usersList = [];
    _userGridArrangedListData = {};
    pointsData = {};
    rankData = {};
    selectedNumbersList = [];
    rank = 1;
  }

  static void addUserGrid(String user, sortedList) {
    _userGridArrangedListData[user] = sortedList;
    pointsData[user] = 0;
  }

  void setUsersList(List<String> usersList) {
    this.usersList = usersList;
    notifyListeners();
  }

  static void findRankPoints() {
    bool rankChanged = false;
    for (String user in pointsData.keys) {
      int p = pointsData[user];
      if (p >= 5 && !rankData.containsKey(user)) {
        rankData[user] = rank;
        rankChanged = true;
      }
    }
    if (rankChanged) rank++;
  }

  static int getUserRankDetail(String user) {
    if (rankData.containsKey(user)) {
      return rankData[user];
    } else {
      return -1;
    }
  }

  static void findPoints() {
    for (String user in _userGridArrangedListData.keys) {
      FindPointsClass findPointsClass =
          FindPointsClass(5, _userGridArrangedListData[user], pointsData[user]);
      findPointsClass.findPoints((int p) {
        pointsData[user] = p;
      });
    }
    print(pointsData);
    findRankPoints();
  }

  void makeSelected(List selectedList) {
    selectedNumbersList = selectedList;
    print(selectedList);
    for (String user in _userGridArrangedListData.keys) {
      for (int num in selectedList) {
        int i = findIndexOfUserList(_userGridArrangedListData[user], num);
        print(i);
        if (i != -1) _userGridArrangedListData[user][i]['selected'] = true;
      }
    }
    findPoints();
    notifyListeners();
  }
}

int findIndexOfUserList(List userArrangedList, int x) {
  int i = 0;
  for (Map item in userArrangedList) {
    if (item['no'] == x) return i;
    i++;
  }
  return -1;
}

// void main() {
//   ScoreCalculator scoreCalculator = ScoreCalculator();
//   scoreCalculator.addUserGrid("amal", [1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12]);
//   scoreCalculator.makeSelected([1, 2, 3, 4, 5, 6]);
//   scoreCalculator.findPoints();
// }
