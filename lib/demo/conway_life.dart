import 'package:flutter/material.dart';

main() => runApp(MaterialApp(home: ConwayLifeApp()));

class ConwayLifeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ConwayLifeWidget(),
      ),
    );
  }
}

class ConwayLifeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Chessboard chessboard = Chessboard();
    return Stack(
      children: <Widget>[
        Align(child: LimitlessGridWidget(chessboard)),
        Align(alignment: Alignment.topCenter, child: ConsoleWidget(chessboard))
      ],
    );
  }
}

class ConsoleWidget extends StatefulWidget {
  final GameController controller;
  final Logcat logcat;

  ConsoleWidget(chessboard)
      : controller = chessboard,
        logcat = chessboard;

  @override
  _ConsoleWidgetState createState() => _ConsoleWidgetState();
}

class _ConsoleWidgetState extends State<ConsoleWidget> {
  String log;

  @override
  void initState() {
    super.initState();
    widget.logcat.printer = (log) {
      setState(() {
        this.log = log;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Text(log ?? "游戏尚未开始，请点击开始按钮"),
            fit: FlexFit.tight,
          ),
          RaisedButton(
            onPressed: () => widget.controller.runningState != 2
                ? widget.controller.play()
                : widget.controller.pause(),
            child: Text("开始/暂停"),
          )
        ],
      ),
    );
  }
}

typedef Printer = void Function(String message);

mixin Logcat {
  Printer printer;

  void printLog(String message) {
    if (printer != null)
      printer?.call(message);
    else
      print(message);
  }
}

mixin GameController {
  /// 运行状态：0表示初始状态，1表示准备就绪，2表示运行中，3表示暂停，4表示已结束
  int runningState = 0;

  void prepare() {
    runningState = 1;
  }

  void play() {
    if (runningState == 2) return;
    runningState = 2;
    _play();
  }

  void pause() {
    if (runningState == 3) return;
    runningState = 3;
    _pause();
  }

  void over() {
    runningState = 4;
  }

  void _play() {}

  void _pause() {}
}

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

class Chessboard with GameController, Logcat {
  List<Coord> lifeList = List<Coord>();
  double scaleFactor = 1.0;
  double gridSize = 20;
  /// 迭代次数
  int count = 0;
  DrawNotify notify;

  void init() {
    lifeList.add(Coord(0, 3));
    lifeList.add(Coord(1, 3));
    lifeList.add(Coord(2, 3));
    lifeList.add(Coord(3, 3));
    lifeList.add(Coord(4, 3));
  }

  void addLife(Coord coord) {
    if (lifeList.contains(coord)) {
      lifeList.remove(coord);
    } else {
      lifeList.add(coord);
    }
    notify?.call();
  }

  void _play() async {
    super.play();
    print("你开始了游戏");
    for (;;) {
      await new Future.delayed(const Duration(milliseconds: 1000));
      if (runningState != 2) return;
      List<Coord> lifeList = this.lifeList;
      printLog("第 ${count++} 代存活细胞数量为 ${lifeList.length}");
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
      if(lifeList.length == 0){
        over();
        return;
      }
    }
  }

  @override
  void _pause() {
    super._pause();
    print("你暂停了游戏");
  }

  @override
  void over() {
    super.over();
    printLog("游戏已结束");
  }
}

class LimitlessGridWidget extends StatefulWidget {
  final Chessboard chessboard;

  LimitlessGridWidget(this.chessboard);

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
    this.chessboard = widget.chessboard;
    chessboard.init();
    chessboard.notify = () {
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 360,
      decoration: _CustomDecoration(chessboard, offset),
      child: GestureDetector(
        onTapUp: (e) {
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
