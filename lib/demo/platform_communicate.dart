import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';

main() {
  runApp(PlatformCommunicateDemo());
}

class PlatformCommunicateDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _HomePage();
  }
}

class _HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler((call) async {
      print("platform: " + call.method);
      if (call.method == "onBackPressed") {
//        Navigator.of(context).pop();
      }
      return true;
    });
  }

  @override
  void dispose() {
    //需要做清除处理，防止影响其它页面
    platform.setMethodCallHandler((call) async => false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          titleSpacing: 0.0,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Text("Platform Communicate"),
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              RaisedButton(child: Text("按返回试试"), onPressed: null),
              RaisedButton(
                  child: Text("发送Toast事件"),
                  onPressed: () {
                    platform
                        .invokeMethod("toast", {"message": "来自Flutter的消息"})
                        .then((value) => print("toast result: $value"))
                        .catchError((e) {
                          print("toast error: $e");
                        });
                  }),
              RaisedButton(
                  child: Text("发送未知事件"),
                  onPressed: () {
                    platform
                        .invokeMethod("unkown", [])
                        .then((value) => print("unkown result: $value"))
                        .catchError((e) {
                          print("unkown error: $e");
                        });
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
