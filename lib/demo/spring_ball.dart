import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

main() => runApp(SpringBallApp());

class SpringBallApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: SpringBallPage());
}

class SpringBallPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: PlaygroundWidget(),
        ),
      ),
    );
  }
}

class PlaygroundWidget extends StatefulWidget {
  @override
  _PlaygroundWidgetState createState() => _PlaygroundWidgetState();
}

class Playground {
  static final double width = 360;
  static final double height = 480;
}

class Ball{
  static final double radius = 48;
}

class _PlaygroundWidgetState extends State<PlaygroundWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: Playground.width,
          height: Playground.height,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.amber),
          ),
        ),
        BallWidget(radius: Ball.radius),
      ],
    );
  }
}

class RunningBall {
  static const double minVelocity = 0.1;
  bool upToDown;
  bool leftToRight;
  Offset velocity;
  double damp;

  RunningBall({
    @required Velocity velocity,
    this.damp = 1.0,
  })  : upToDown = velocity.pixelsPerSecond.dy > 0,
        leftToRight = velocity.pixelsPerSecond.dx > 0,
        velocity = Offset(velocity.pixelsPerSecond.dx.abs(),
            velocity.pixelsPerSecond.dy.abs()),
        assert(damp > 0 && damp < 10);

  Offset nextOffset(Offset position) {
    Offset deltaVelocity = velocity * damp / 100;
    deltaVelocity = Offset(math.max(deltaVelocity.dx.abs(), minVelocity),
        math.max(deltaVelocity.dy.abs(), minVelocity));
    velocity = velocity - deltaVelocity;
    velocity = Offset(
        velocity.dx <= 0 ? 0 : velocity.dx, velocity.dy <= 0 ? 0 : velocity.dy);
    if (position.dy >= Playground.height - Ball.radius) {
      position = Offset(position.dx, Playground.height - Ball.radius);
      upToDown = false;
    } else if (position.dy <= 0) {
      position = Offset(position.dx, 0);
      upToDown = true;
    }
    if (position.dx >= Playground.width - Ball.radius) {
      position = Offset(Playground.width - Ball.radius, position.dy);
      leftToRight = false;
    } else if (position.dx <= 0) {
      position = Offset(0, position.dy);
      leftToRight = true;
    }
    return position.translate(
        leftToRight ? deltaVelocity.dx : -deltaVelocity.dx,
        upToDown ? deltaVelocity.dy : -deltaVelocity.dy);
  }
}

class BallWidget extends StatefulWidget {
  final double radius;

  const BallWidget({Key key, this.radius}) : super(key: key);
  @override
  _BallWidgetState createState() => _BallWidgetState();
}

class _BallWidgetState extends State<BallWidget>
    with SingleTickerProviderStateMixin {
  Ticker _ticker;
  RunningBall _ball;

  Offset position = Offset(162, 162);
  bool down = true;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((e) {
      if (_ball == null) return;
      if (_ball.velocity.dx > 0 || _ball.velocity.dy > 0) {
        position = _ball.nextOffset(position);
        setState(() {});
      } else {
        _ticker.stop();
      }
    });
  }

  @override
  void dispose() {
    _ticker.stop();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        child: Container(
          width: widget.radius,
          height: widget.radius,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.brown.shade700),
            color: Colors.brown,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
          child: GestureDetector(
            onVerticalDragEnd: (d) {
              _ball = RunningBall(velocity: d.velocity);
              _ticker.start();
            },
            onVerticalDragDown: (d) {
              _ball = null;
              _ticker.stop(canceled: true);
            },
          ),
        ),
        left: position.dx,
        top: position.dy);
  }
}
