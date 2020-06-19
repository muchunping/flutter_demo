import 'dart:async';

import 'package:flutter/material.dart';

main() => runApp(JumperApp());

class JumperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: JumperPage());
}

class JumperPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          color: Colors.white,
          child: JumperWidget(data: [Jumper(1), Jumper(2), Jumper(3)]),
        ),
      ),
    );
  }
}

typedef JumpNotify = void Function(int m);

class Jumper {
  int count;
  final int initCount;

  Jumper(this.count):initCount = count;

  JumpNotify notify;
}

class JumperWidget extends StatefulWidget {
  final List<Jumper> data;

  const JumperWidget({Key key, this.data}) : super(key: key);

  @override
  _JumperWidgetState createState() => _JumperWidgetState();
}

class _JumperWidgetState extends State<JumperWidget> {
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      widget.data.forEach((e) {
        e.count++;
        e.notify?.call(widget.data.length);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: widget.data.map((e) => JumperView(jumper: e)).toList(),
    );
  }
}

class JumperView extends StatefulWidget {
  final Jumper jumper;

  const JumperView({Key key, this.jumper}) : super(key: key);

  @override
  _JumperViewState createState() => _JumperViewState();
}

class _JumperViewState extends State<JumperView>
    with SingleTickerProviderStateMixin<JumperView> {
  AnimationController _positionController;
  Animation<Offset> _positionFactor;

  @override
  void initState() {
    super.initState();
    _positionController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _positionFactor = _positionController.drive(
        Tween(begin: Offset(0, 0), end: Offset(0, -0.3))
            .chain(CurveTween(curve: Curves.easeInQuart)));
    widget.jumper.notify = jump;
  }

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }

  void jump(int m) {
    if (widget.jumper.count % m != 0) return;
    _positionController
        .animateTo(1.0)
        .whenComplete(() => _positionController.animateTo(0.0));
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _positionFactor,
      child: CustomPaint(
          painter: _JumperPainter(widget.jumper), size: Size(64.0, 64.0)),
    );
  }
}

class _JumperPainter extends CustomPainter {
  final Jumper jumper;

  _JumperPainter(this.jumper);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.amber
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle((Offset.zero & size).center,
        size.width > size.height ? size.height / 2 : size.width / 2, paint);
    var textPainter = TextPainter(
      text: TextSpan(
        text: "${jumper.count}",
        style: TextStyle(color: Colors.red),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    var offset = Offset((size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_JumperPainter old) {
    return false;
  }
}
