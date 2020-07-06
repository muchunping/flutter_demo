import 'dart:ui';

import 'package:flutter/material.dart';

import 'decoration_custom.dart';

main() => runApp(MaterialApp(home: FightBallApp()));

const int rowCount = 3;
const int columnCount = 3;

class FightBallApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            width: 360,
            height: 780,
            color: Colors.amber,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: TopArrayWidget(),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 360,
                    height: 80,
                    color: Colors.white,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BottomArrayWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BattleField{
  TopArray topArray;
  BottomArray bottomArray;


  get nextActor => topArray.fighterList.values.elementAt(0);
}

class TopArrayWidget extends StatefulWidget {
  @override
  _TopArrayWidgetState createState() => _TopArrayWidgetState();
}

class _TopArrayWidgetState extends State<TopArrayWidget> {
  TopArray topArray;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((d) {
      Rect rect = context.findRenderObject().paintBounds;
      topArray = TopArray(rect);
      topArray.addFighter(
          Fighter("张辽", 2, intensity: 2), ArraySlotPosition(0, 0));
      topArray.addFighter(
          Fighter("司马懿", 3, intensity: 1), ArraySlotPosition(0, 1));
      topArray.arrayChanged = () {
        setState(() {});
      };
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 320,
      decoration: _GridDecoration(backgroundColor: Colors.white70),
      child: topArray != null
          ? Stack(
              children: topArray.fighterList.entries.map((e) {
              Rect rect = topArray.slotMap[e.key];
              Fighter fighter = e.value;
              return Positioned(
                left: rect.left,
                top: rect.top,
                child: Container(
                  width: rect.width,
                  height: rect.height,
                  alignment: Alignment.center,
                  child: PretenderWidget(
                      dataObject: Pretender(fighter.name, fighter.star,
                          intensity: fighter.intensity)),
                ),
              );
            }).toList())
          : null,
    );
  }
}

class BottomArrayWidget extends StatefulWidget {
  @override
  _BottomArrayWidgetState createState() => _BottomArrayWidgetState();
}

class _BottomArrayWidgetState extends State<BottomArrayWidget> {
  BottomArray bottomArray;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((d) {
      Rect rect = context.findRenderObject().paintBounds;
      bottomArray = BottomArray(rect);
      bottomArray.addFighter(
          Fighter("诸葛亮", 3, intensity: 3), ArraySlotPosition(0, 0));
      bottomArray.addFighter(
          Fighter("廖化", 1, intensity: 1), ArraySlotPosition(0, 1));
      bottomArray.arrayChanged = () {
        setState(() {});
      };
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 320,
      decoration: _GridDecoration(backgroundColor: Colors.white70),
      child: bottomArray != null
          ? Stack(
              children: bottomArray.fighterList.entries.map((e) {
              Rect rect = bottomArray.slotMap[e.key];
              Fighter fighter = e.value;
              return Positioned(
                left: rect.left,
                top: rect.top,
                child: Container(
                  width: rect.width,
                  height: rect.height,
                  alignment: Alignment.center,
                  child: PretenderWidget(
                      dataObject: Pretender(fighter.name, fighter.star,
                          intensity: fighter.intensity)),
                ),
              );
            }).toList())
          : null,
    );
  }
}

class ArraySlotPosition {
  final int rowIndex;
  final int columnIndex;

  ArraySlotPosition(this.rowIndex, this.columnIndex);

  @override
  bool operator ==(other) {
    return other is ArraySlotPosition &&
        other.columnIndex == this.columnIndex &&
        other.rowIndex == this.rowIndex;
  }

  @override
  int get hashCode => hashValues(columnIndex, rowIndex);
}

class Fighter {
  final String name;
  final int star;
  int intensity;

  double energy;

  Fighter(this.name, this.star, {this.intensity});
}

typedef ArrayChanged = void Function();

class TopArray {
  Map<ArraySlotPosition, Rect> slotMap = Map();
  Map<ArraySlotPosition, Fighter> fighterList = Map();
  ArrayChanged arrayChanged;

  void addFighter(Fighter fighter, ArraySlotPosition position) {
    fighterList[position] = fighter;
  }

  TopArray(Rect rect) {
    var width = rect.width / (rowCount + 1);
    var height = rect.height / (columnCount + 1);
    var spaceH = width / (rowCount + 1);
    var spaceV = height / (columnCount + 1);
    var firstRect = Rect.fromLTWH(spaceH, spaceV, width, height)
        .translate(rect.topLeft.dx, rect.topLeft.dy);
    if (rowCount % 2 == 0) firstRect = firstRect.translate(spaceH / 2, 0);
    if (columnCount % 2 == 0) firstRect = firstRect.translate(0, spaceV / 2);
    for (int i = 0; i < columnCount; i++) {
      double dy = (height + spaceV) * i;
      for (int j = 0; j < rowCount; j++) {
        double dx = (width + spaceH) * j;
        slotMap[ArraySlotPosition(columnCount - i - 1, j)] =
            firstRect.translate(dx, dy);
      }
    }
  }
}

class BottomArray {
  Map<ArraySlotPosition, Rect> slotMap = Map();
  Map<ArraySlotPosition, Fighter> fighterList = Map();
  ArrayChanged arrayChanged;

  void addFighter(Fighter fighter, ArraySlotPosition position) {
    fighterList[position] = fighter;
  }

  BottomArray(Rect rect) {
    var width = rect.width / (rowCount + 1);
    var height = rect.height / (columnCount + 1);
    var spaceH = width / (rowCount + 1);
    var spaceV = height / (columnCount + 1);
    var firstRect = Rect.fromLTWH(spaceH, spaceV, width, height)
        .translate(rect.topLeft.dx, rect.topLeft.dy);
    if (rowCount % 2 == 0) firstRect = firstRect.translate(spaceH / 2, 0);
    if (columnCount % 2 == 0) firstRect = firstRect.translate(0, spaceV / 2);
    for (int i = 0; i < columnCount; i++) {
      double dy = (height + spaceV) * i;
      for (int j = 0; j < rowCount; j++) {
        double dx = (width + spaceH) * j;
        slotMap[ArraySlotPosition(i, j)] = firstRect.translate(dx, dy);
      }
    }
  }
}

class _GridDecoration extends Decoration {
  final Color backgroundColor;

  _GridDecoration({this.backgroundColor});

  @override
  BoxPainter createBoxPainter([onChanged]) {
    return _GridBoxPainter(backgroundColor);
  }
}

class _GridBoxPainter extends BoxPainter {
  final Color backgroundColor;
  final int column = 3;
  final int row = 3;

  _GridBoxPainter(this.backgroundColor);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = offset & configuration.size;
    var backgroundPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = backgroundColor;
    canvas.drawRect(rect, backgroundPaint);
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white;
    canvas.drawRect(rect, paint);
    var width = rect.width / (row + 1);
    var height = rect.height / (column + 1);
    var spaceH = width / (row + 1);
    var spaceV = height / (column + 1);
    var firstRect = Rect.fromLTWH(spaceH, spaceV, width, height)
        .translate(offset.dx, offset.dy);
    if (row % 2 == 0) firstRect = firstRect.translate(spaceH / 2, 0);
    if (column % 2 == 0) firstRect = firstRect.translate(0, spaceV / 2);
    for (int i = 0; i < column; i++) {
      double dy = (height + spaceV) * i;
      for (int j = 0; j < row; j++) {
        double dx = (width + spaceH) * j;
        var rect = firstRect.translate(dx, dy);
        canvas.drawRect(rect, paint);
      }
    }
  }
}
