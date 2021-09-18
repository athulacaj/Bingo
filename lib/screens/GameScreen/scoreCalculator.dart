import 'package:bingo/utility/functions/findPoints.dart';

class ScoreCalculator {
  List _itemsSelected = [];
  static Map _userGridArrangedListData = {};
  static Map pointsData = {};
  ScoreCalculator() {
    // _itemsSelected = [];
    // _userGridArrangedListData = {};
  }
  static void addUserGrid(String user, sortedList) {
    List<Map> _numbersList = [];
    for (int no in sortedList) {
      _numbersList.add({
        'no': no,
        'selected': false,
        'vertical': false,
        'horizontal': false,
        'diagonal': false,
        'diagonalOp': false,
      });
    }
    _userGridArrangedListData[user] = _numbersList;
    pointsData[user] = 0;
  }

  void findPoints() {
    for (String user in _userGridArrangedListData.keys) {
      FindPointsClass findPointsClass =
          FindPointsClass(5, _userGridArrangedListData[user], pointsData[user]);
      findPointsClass.findPoints((int p) {
        pointsData[user] = p;
        print("point: $p");
      });
    }
  }

  void makeSelected(List selectedList) {
    print(_userGridArrangedListData);
    for (String user in _userGridArrangedListData.keys) {
      for (int num in selectedList) {
        int i = findIndexOfUserList(_userGridArrangedListData[user], num);
        print(i);
        if (i != -1) _userGridArrangedListData[user][i]['selected'] = true;
      }
    }
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
