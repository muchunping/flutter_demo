import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

main() => runApp(GuillotineMenuDemo());

class GuillotineMenuDemo extends StatelessWidget {
  Widget buildMainPage() {
    return Container(
      color: Color(0xff393449),
    );
  }

  Widget buildMenuPage() {
    var style = TextStyle(
        letterSpacing: 2.0,
        color: Colors.white,
        fontSize: 16.0,
        decoration: TextDecoration.none);
    return Container(
      alignment: Alignment.topLeft,
      color: Color(0xff413f52),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.translate, color: Colors.white),
                Padding(padding: EdgeInsets.only(left: 8.0)),
                Text("TRANSLATE", style: style)
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 8.0)),
            Row(
              mainAxisSize: MainAxisSize.min,
//            mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.save, color: Colors.white),
                Padding(padding: EdgeInsets.only(left: 8.0)),
                Text("SAVE", style: style)
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 8.0)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.satellite, color: Colors.white),
                Padding(padding: EdgeInsets.only(left: 8.0)),
                Text("SATELLITE", style: style)
              ],
            ),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: MaterialApp(
        theme: ThemeData(textTheme: TextTheme()),
        home: Guillotine(mainPage: buildMainPage(), menuPage: buildMenuPage()),
      ),
    );
  }
}

class Guillotine extends StatefulWidget {
  final Widget mainPage;
  final Widget menuPage;

  const Guillotine({Key key, this.mainPage, this.menuPage}) : super(key: key);

  @override
  State<Guillotine> createState() => GuillotineState();
}

class GuillotineState extends State<Guillotine>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;
  var pressCallback;
  var titleStyle = TextStyle(
      letterSpacing: 2.0,
      color: Colors.white,
      fontSize: 18.0,
      decoration: TextDecoration.none);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _animation = Tween(begin: 0.0, end: -pi / 2).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut,
        reverseCurve: Curves.bounceIn));
    _controller.addListener(() {
      setState(() {});
    });

    pressCallback = () {
      if (_animation.status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (_animation.status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildMenuTitle() {
    var opacity = 1 + _animation.value * 1.2;
    return Container(
      width: double.infinity,
      height: 80.0,
      color: Color(0xff413f52),
      padding: EdgeInsets.only(top: 24.0),
      child: Row(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(left: 4.0)),
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white, size: 24.0),
            onPressed: pressCallback,
          ),
          Padding(padding: EdgeInsets.only(left: 4.0)),
          Opacity(
            opacity: opacity < 0 ? 0 : opacity,
            child: Text("ACTIVITY", style: titleStyle),
          )
        ],
      ),
    );
  }

  Widget buildMenuLayout() {
    var opacity = -_animation.value - 0.4;
    if (opacity < 0.0) {
      opacity = 0.0;
    } else if (opacity > 1.0) {
      opacity = 1.0;
    }
    return Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        widget.menuPage,
        Transform.rotate(
          angle: pi / 2,
          origin: Offset(-52.0, 28.0),
          child: Opacity(
            opacity: opacity,
            child: Container(
              child: Text("ACTIVITY", style: titleStyle),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.mainPage,
        Transform.rotate(
          alignment: Alignment.topLeft,
          angle: _animation.value,
          child: Column(
            children: <Widget>[
              buildMenuTitle(),
              Expanded(
                child: buildMenuLayout(),
              )
            ],
          ),
          origin: Offset(28.0, 52.0),
        ),
      ],
    );
  }
}
