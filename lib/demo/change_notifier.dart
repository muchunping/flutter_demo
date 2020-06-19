import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

main() {
  runApp(ChangeNotifierDemo());
}

const Size uxSize = Size(480, 1080);
final MediaQueryData display = MediaQueryData.fromWindow(window);
final scale = (display.size.width - display.padding.horizontal) / uxSize.width;

class ChangeNotifierDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Protagonist()),
      ],
      child: MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.greenAccent,
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Header(),
                Neck(),
                Expanded(child: Body()),
                Footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Protagonist extends ChangeNotifier {
  String _name = "张三";

  String get name => _name;

  set name(String name) {
    _name = name;
    notifyListeners();
  }
}

class Header extends StatefulWidget {
  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200 * scale,
      color: Colors.greenAccent,
      child: Center(child: Text(context.watch<Protagonist>().name)),
    );
  }
}

class Neck extends StatefulWidget {
  @override
  _NeckState createState() => _NeckState();
}

class _NeckState extends State<Neck> {
  @override
  Widget build(BuildContext context) {
    print(display);
    return Container(
      height: 48 * scale,
      color: Colors.lightGreen,
    );
  }
}

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: 1080 * scale,
        color: Colors.lightGreenAccent,
        child: Center(
          child: IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (c) {
                  return UpdatePage();
                }));
              }),
        ),
      ),
    );
  }
}

class Footer extends StatefulWidget {
  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> with SingleTickerProviderStateMixin {
  double height = 30 * scale;
  AnimationController _controller;
  Animation _animation;
  int _countdown = 5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    Tween tween = Tween(begin: height, end: 0.0);
    _animation = tween.animate(_controller);
    _animation.addListener(() {
      setState(() {});
    });
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timer.tick >= 5) {
          timer.cancel();
          _controller.forward();
          context.read<Protagonist>().name = "李四";
        } else {
          _countdown = 5 - timer.tick;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: _animation?.value ?? height,
      color: Colors.green,
      child: Text("$_countdown秒后自动修改名字为：李四"),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class UpdatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Page")),
      body: Container(
        child: RaisedButton(
            child: Text("点击按钮修改名字为：王五"),
            onPressed: () {
              context.read<Protagonist>().name = "王五";
            }),
      ),
    );
  }
}
