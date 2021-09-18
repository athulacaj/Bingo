import 'dart:math';

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
