import 'package:bingo/Colors.dart';
import 'package:flutter/material.dart';

class MyCustomBoxPaint extends CustomPainter {
  double radius = 10;
  final Map data;
  final bool isRecentlySelected;
  MyCustomBoxPaint({required this.data, required this.isRecentlySelected});
  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width;
    double height = size.height;
    // draw box and background
    drawBox(canvas, width, height, data['selected']);

    //
    //
    //

    Offset setPoint = Offset(0, 0);
    if (data.containsKey("labelV")) {
      setPoint = Offset(width / 2 - 3, height + 5);
      paintLabelPoint(canvas, setPoint, data['labelV']);
    }
    if (data.containsKey("labelH")) {
      paintLabelPoint(
          canvas, Offset(width + 5, height / 2 - 13), data['labelH']);
    }
    if (data.containsKey("labelD")) {
      paintLabelPoint(canvas, Offset(width + 5, height + 3), data['labelD']);
    }
    if (data.containsKey("labelO")) {
      paintLabelPoint(canvas, Offset(-10, height + 5), data['labelO']);
    }

    //
    //
    drawPointLine(canvas, width, height);

    data['selected'] == true
        ? drawCross(canvas, width, height, isRecentlySelected)
        : null;
  }

  void paintLabelPoint(Canvas canvas, Offset setPoint, int point) {
    String bingo = "BINGO            ";
    TextSpan span = new TextSpan(
      style: new TextStyle(
          color: Colors.green,
          fontSize: 16,
          backgroundColor: bingo[point - 1] == " " ? null : Colors.white,
          fontWeight: FontWeight.w600),
      text: bingo[point - 1],
    );
    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, setPoint);
  }

  void drawPointLine(Canvas canvas, double width, double height) {
    var paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    data['diagonal']
        ? canvas.drawLine(Offset(0, 0), Offset(width, height), paint)
        : null;

    data['diagonalOp']
        ? canvas.drawLine(Offset(0, height), Offset(width, 0), paint)
        : null;
    data['vertical']
        ? canvas.drawLine(
            Offset(width / 2, 0), Offset(width / 2, height), paint)
        : null;
    data['horizontal']
        ? canvas.drawLine(
            Offset(0, height / 2), Offset(width, height / 2), paint)
        : null;
  }

  void drawCross(
      Canvas canvas, double width, double height, bool isRecentlySelected) {
    var paint = Paint()
      ..color = isRecentlySelected ? topColor : Colors.black26
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    //horizontal
    canvas.drawLine(Offset(width * .3, height / 2.4),
        Offset(width * .7, height / 1.7), paint);
    //vertical
    canvas.drawLine(Offset(width / 1.75, height * .3),
        Offset(width / 2.3, height * .7), paint);
  }

  void drawBox(
    Canvas canvas,
    double width,
    double height,
    bool selected,
  ) {
    var paint = Paint();
    paint.color = selected
        ? Colors.white.withOpacity(0.85)
        : Colors.white.withOpacity(.97);
    paint.strokeWidth = 2;
    var boxPath = Path();
    boxPath.lineTo(0, height);
    boxPath.lineTo(width, height);
    boxPath.lineTo(width, 0);
    boxPath.close();
    canvas.drawPath(boxPath, paint);
    // draw a border
    drawBorder(canvas, width, height);
  }

  void drawBorder(Canvas canvas, double width, double height) {
    var paint = Paint();
    paint.strokeWidth = .2;
    paint.color = Colors.black;
    canvas.drawLine(Offset(0, 0), Offset(width, 0), paint);
    canvas.drawLine(Offset(width, 0), Offset(width, height), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, height), paint);
    canvas.drawLine(Offset(0, height), Offset(width, height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    // throw UnimplementedError();
    return false;
  }
}
