import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const double maxTime = 3000.0;

main() => runApp(MaterialApp(home: RunningBallApp()));

class RunningBallApp extends StatelessWidget {
  final intruderArray = [Ball(124.1), Ball(101.2), Ball(109.3)];
  final defenderArray = [Ball(110.4), Ball(115.5), Ball(121.6)];

  @override
  Widget build(BuildContext context) {
    Playground playground = Playground()
      ..setupIntruder(intruderArray)
      ..setupDefender(defenderArray);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            width: 360,
            height: 720,
            child: PlaygroundWidget(playground: playground),
          ),
        ),
      ),
    );
  }
}

class Playground {
  Map<ArraySlotPosition, Rect> topSlotPositionMap = Map();
  Map<ArraySlotPosition, Rect> bottomSlotPositionMap = Map();
  List<RunningBall> topArray = List();
  List<RunningBall> bottomArray = List();
  static const int row = 3;
  static const int column = 3;

  computeSlotPosition(double arrayWidth, double arrayHeight) {
    var width = arrayWidth / (row + 1);
    var height = arrayHeight / (column + 1);
    var spaceH = width / (row + 1);
    var spaceV = height / (column + 1);
    var firstRect = Rect.fromLTWH(spaceH, spaceV, width, height);
    if (row % 2 == 0) firstRect = firstRect.translate(spaceH / 2, 0);
    if (column % 2 == 0) firstRect = firstRect.translate(0, spaceV / 2);
    for (int i = 0; i < column; i++) {
      double dy = (height + spaceV) * i;
      for (int j = 0; j < row; j++) {
        double dx = (width + spaceH) * j;
        var rect = firstRect.translate(dx, dy);
        topSlotPositionMap[ArraySlotPosition(column - i - 1, j)] = rect;
        bottomSlotPositionMap[ArraySlotPosition(i, j)] = rect;
      }
    }
  }

  void setupIntruder(List<Ball> intruderArray) {
    bottomArray = intruderArray.map((e) => RunningBall(e, true)).toList();
    _setupPosition(bottomArray);
  }

  void setupDefender(List<Ball> defenderArray) {
    topArray = defenderArray.map((e) => RunningBall(e, false)).toList();
    _setupPosition(topArray);
  }

  void _setupPosition(Iterable<RunningBall> iterable) {
    int i = 0;
    int j = 0;
    iterable.forEach((e) {
      e.position = ArraySlotPosition(i, j);
      j++;
      if (j == Playground.row) {
        j = 0;
        i++;
      }
    });
  }

  Future<void> play() async {
    double time = 0;
    int count = 0;
    assert(topArray.isNotEmpty && bottomArray.isNotEmpty);
    for (;;) {
      await new Future.delayed(const Duration(milliseconds: 1000));
      print("----- ${count++} -----");
      RunningBall nextBall;
      var allArray = topArray.followedBy(bottomArray);
      allArray.forEach((e) {
        if (e.time < (nextBall?.time ?? double.infinity)) nextBall = e;
      });
      final deltaTime = nextBall.time;
      time += deltaTime;
      print("当前时序 = $time");
      allArray.forEach((e) {
        e.time -= deltaTime;
        if (e.time <= 0) e.time += e.ball.duration;
      });
      nextBall.play();
      if (time > maxTime) {
        print("over time!");
        return;
      }
    }
  }
}

class PlaygroundWidget extends StatefulWidget {
  final Playground playground;

  const PlaygroundWidget({Key key, this.playground}) : super(key: key);

  @override
  _PlaygroundWidgetState createState() => _PlaygroundWidgetState();
}

class _PlaygroundWidgetState extends State<PlaygroundWidget> {
  double arrayWidth = 320;
  double arrayHeight = 320;

  @override
  void initState() {
    super.initState();
    widget.playground.computeSlotPosition(arrayWidth, arrayHeight);
    WidgetsBinding.instance.addPostFrameCallback((d) {
      setState(() {
        widget.playground.play();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: arrayWidth,
            height: arrayHeight,
            decoration: _GridDecoration(
              widget.playground.topSlotPositionMap.values,
              backgroundColor: Color(0x33FF0000),
            ),
            child: ArrayWidget(
              array: widget.playground.topArray,
              slotMap: widget.playground.topSlotPositionMap,
            ),
          ),
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
          child: Container(
            width: arrayWidth,
            height: arrayHeight,
            decoration: _GridDecoration(
              widget.playground.bottomSlotPositionMap.values,
              backgroundColor: Color(0x33FF00FF),
            ),
            child: ArrayWidget(
              array: widget.playground.bottomArray,
              slotMap: widget.playground.bottomSlotPositionMap,
            ),
          ),
        )
      ],
    );
  }
}

class ArrayWidget extends StatefulWidget {
  final List<RunningBall> array;
  final Map<ArraySlotPosition, Rect> slotMap;

  const ArrayWidget({Key key, this.array, this.slotMap}) : super(key: key);

  @override
  _ArrayWidgetState createState() => _ArrayWidgetState();
}

class _ArrayWidgetState extends State<ArrayWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((d) {
      Offset offset =
          (context.findRenderObject() as RenderBox).localToGlobal(Offset.zero);
      widget.slotMap.values.forEach((e) => e.translate(offset.dx, offset.dy));
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: widget.array.map(
        (e) {
          Rect rect = widget.slotMap[e.position];
          return Positioned(
            left: rect.left,
            top: rect.top,
            child: Container(
              width: rect.width,
              height: rect.height,
              alignment: Alignment.center,
              child: BallWidget(ball: e),
            ),
          );
        },
      ).toList(),
    );
  }
}

typedef PlayNotify = void Function(int m);

class RunningBall {
  final Ball ball;
  final bool isIntruder;
  ArraySlotPosition position;
  double time;
  PlayNotify notify;

  RunningBall(this.ball, this.isIntruder) : time = ball.duration;

  void play() {
    notify?.call(0);
    print("$this action");
  }

  @override
  String toString() {
    return 'RunningBall{ball: $ball, time: $time}';
  }
}

class Ball {
  final double duration;

  Ball(this.duration);

  @override
  String toString() {
    return 'Ball{duration: $duration}';
  }
}

class _GridDecoration extends Decoration {
  final Color backgroundColor;
  final Iterable<Rect> slotPositions;

  _GridDecoration(this.slotPositions, {this.backgroundColor});

  @override
  BoxPainter createBoxPainter([onChanged]) {
    return _GridBoxPainter(slotPositions, backgroundColor);
  }
}

class _GridBoxPainter extends BoxPainter {
  final Color backgroundColor;
  final Iterable<Rect> slotPositions;

  _GridBoxPainter(this.slotPositions, this.backgroundColor);

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
    slotPositions.forEach((e) {
      canvas.drawRect(e.translate(offset.dx, offset.dy), paint);
    });
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

class BallWidget extends StatefulWidget {
  final RunningBall ball;

  const BallWidget({Key key, this.ball}) : super(key: key);

  @override
  _BallWidgetState createState() => _BallWidgetState();
}

class _BallWidgetState extends State<BallWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _positionController;
  Animation<Offset> _positionFactor;

  @override
  void initState() {
    super.initState();
    _positionController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    int direction = widget.ball.isIntruder ? -1 : 1;
    _positionFactor = _positionController.drive(
        Tween(begin: Offset(0, 0), end: Offset(0, 0.3 * direction))
            .chain(CurveTween(curve: Curves.easeInQuart)));
    widget.ball.notify = play;
  }

  void play(int i) {
    _positionController
        .animateTo(1.5)
        .whenComplete(() => _positionController.animateTo(0.0));
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _positionFactor,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(18.0))),
        alignment: Alignment.center,
        child: Text(widget.ball.ball.duration.toString()),
      ),
    );
  }
}
