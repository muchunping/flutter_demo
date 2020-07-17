import 'package:flutter/material.dart';

main() => runApp(MaterialApp(home: ConwayLifeApp()));

class ConwayLifeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(child: LimitlessGridWidget()),
      ),
    );
  }
}

//class Life {
//  bool isAlive;
//  final Coord coord;
//
//  Life(this.coord);
//}

class Coord {
  final int x;
  final int y;

  Coord(this.x, this.y);

  get neighbor => <Coord>[
        Coord(x + 1, y + 1),
        Coord(x + 1, y - 1),
        Coord(x + 1, y),
        Coord(x - 1, y + 1),
        Coord(x - 1, y - 1),
        Coord(x - 1, y),
        Coord(x, y + 1),
        Coord(x, y - 1),
      ];

  @override
  bool operator ==(other) {
    return other is Coord && other.x == this.x && other.y == this.y;
  }

  @override
  int get hashCode => hashValues(x, y);
}

typedef DrawNotify = void Function();

class Chessboard {
  List<Coord> lifeList = List<Coord>();
  double scaleFactor = 1.0;
  double gridSize = 20;
  DrawNotify notify;

  void init() {
    lifeList.add(Coord(0, 3));
    lifeList.add(Coord(1, 3));
    lifeList.add(Coord(2, 3));
    lifeList.add(Coord(3, 3));
    lifeList.add(Coord(4, 3));
  }

  void addLife(Coord coord) {
    lifeList.add(coord);
    notify?.call();
  }

  void play() async {
    int count = 0;
    for (;;) {
      await new Future.delayed(const Duration(milliseconds: 1000));
      List<Coord> lifeList = this.lifeList;
      print("Chessboard#play(第 ${count ++} 代存活细胞数量为 ${lifeList.length})");
      var influencedList = Set<Coord>();
      lifeList.forEach((e) {
        influencedList.addAll(e.neighbor);
      });
      var newLifeList = List<Coord>();
      influencedList.forEach((e) {
        var length = e.neighbor.where((e) => lifeList.contains(e)).length;
        if (length > 1 && length < 4) {
          if (length == 3) {
            newLifeList.add(e);
          } else if (lifeList.contains(e)) {
            newLifeList.add(e);
          }
        }
      });
      this.lifeList = newLifeList;
      notify?.call();
    }
  }
}

class LimitlessGridWidget extends StatefulWidget {
  @override
  _LimitlessGridWidgetState createState() => _LimitlessGridWidgetState();
}

class _LimitlessGridWidgetState extends State<LimitlessGridWidget> {
  Chessboard chessboard;
  Offset offset = Offset.zero;
  Offset start;

  @override
  void initState() {
    super.initState();
    chessboard = Chessboard()..init();
    chessboard.notify = () {
      setState(() {});
    };
    chessboard.play();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 360,
      decoration: _CustomDecoration(chessboard, offset),
      child: GestureDetector(
        onTapDown: (e) {
          Rect rect = context.findRenderObject().paintBounds;
          var point =
              (e.localPosition - rect.center - offset) / chessboard.gridSize;
          chessboard.addLife(Coord(point.dx.round(), point.dy.round()));
        },
        onScaleStart: (d) {
          start = d.focalPoint;
        },
        onScaleUpdate: (d) {
          setState(() {
            if ((d.scale - 1).abs() > d.rotation.abs()) {
              //scale
            } else if (d.rotation != 0) {
              //rotate
            } else {
              offset = offset.translate(
                  d.focalPoint.dx - start.dx, d.focalPoint.dy - start.dy);
              start = d.focalPoint;
            }
          });
        },
      ),
    );
  }
}

class _CustomDecoration extends Decoration {
  final Chessboard chessboard;
  final Offset offset;

  _CustomDecoration(this.chessboard, this.offset);

  @override
  BoxPainter createBoxPainter([onChanged]) {
    return _CustomBoxPainter(chessboard, offset);
  }
}

class _CustomBoxPainter extends BoxPainter {
  final Chessboard chessboard;
  final Offset offset;

  _CustomBoxPainter(this.chessboard, this.offset);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = offset & configuration.size;
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.amber;
    canvas.drawRect(rect, paint);

    var gridPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue;
    Rect centerRect = Rect.fromCenter(
      center: rect.center,
      width: chessboard.gridSize,
      height: chessboard.gridSize,
    );
    centerRect = centerRect.translate(this.offset.dx, this.offset.dy);
    chessboard.lifeList.forEach((e) {
      double translateX = chessboard.gridSize * e.x;
      double translateY = chessboard.gridSize * e.y;
      Rect lifeRect = centerRect.translate(translateX, translateY);
      canvas.drawRect(lifeRect, gridPaint);
    });
  }
}
