const double maxTime = 3000.0;

main() {
  var ballArray = [
    Ball(124),
    Ball(101),
    Ball(109),
  ];

  var runningBallArray = ballArray.map((e) => RunningBall(e)).toList();

  Future<void> run() async {
    double time = 0;
    int count = 0;
    assert(runningBallArray.isNotEmpty);
    for (;;) {
      await new Future.delayed(const Duration(milliseconds: 1000));
      print("----- ${count ++} -----");
      RunningBall nextBall;
      runningBallArray.forEach((e) {
        if (e.time < (nextBall?.time ?? double.infinity)) nextBall = e;
      });
      final deltaTime = nextBall.time;
      time += deltaTime;
      print("当前时序 = $time");
      runningBallArray.forEach((e) {
        e.time -= deltaTime;
        if(e.time <=0) e.time += e.ball.duration;
      });
      nextBall.action();
      if (time > maxTime) {
        print("over time!");
        return;
      }
    }
  }

  run();
}

class RunningBall {
  final Ball ball;
  double time;

  RunningBall(this.ball) : time = ball.duration;

  void action(){
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
