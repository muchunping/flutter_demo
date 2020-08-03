import 'dart:async';
import 'dart:io';

import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'main.dart';

main() {
  print("main#1");
//  test8();
  runApp(MaterialApp(home: ConverseApp()));
  print("main#2");
}

void test1() {
  print("test1#1");
  Future(() => print('f1'));
  Future(() => print('f2'));
  print("test1#2");
}

void test2() {
  print("test2#1");
  Future(() => print('f1')).then((_) => print('f1t1'));
  Future(() => print('f2'));
  print("test2#2");
}

void test3() {
  print("test3#1");
  Future(() => print('f1')).then((_) => print('f1t1')).then((_) {
    print("f1t2");
    Future(() => print('f2'));
  }).then((_) => print('f1t3'));
  Future(() => print('f3')).then((value) => null);
  print("test3#2");
}

void test4() {
  print("test4#1");
  Future(() => print('f1'))
      .then((_) => print('f1t1'))
      .then((_) {
        print("f1t2");
        Future(() => print('f2'));
      })
      .then((_) => print('f1t3'))
      .then((_) {
        print("f1t4");
        return Future(() => print('f3'));
      })
      .then((_) => print('f1t5'));
  Future(() => print('f4'));
  print("test4#2");
}

void test5() {
  Process.start("process-mu", <String>[]).then((value) => null);
  Future(() => print("future"))
      .then((value) => print("then"))
      .whenComplete(() => print("complete"))
      .catchError((e) => print(e))
      .timeout(Duration(seconds: 1), onTimeout: () => print("timeout"));
}

void test6() {
  Future(() {
    print('future');
    var a = "1";
    a.substring(0, 2);
    return 1;
  }).then((value) {
    print("then1 = $value");
    return 2;
  }, onError: (e) {
    print("then error: $e");
  }).whenComplete(() {
    print("complete");
  }).then((value) {
    print("then2 = $value");
    return Future(() {
      print("future2");
      throw "exception occur";
    });
  }).catchError((e) {
    print("catch error: $e");
  }).timeout(Duration(seconds: 1), onTimeout: () {
    print("timeout");
  });
}

void test7() {
  print("test7#1");
  httpGet().whenComplete(() => print("http get complete"));
  print("test7#2");
}

Future<int> httpGet() async {
  return await Future.delayed(Duration(seconds: 1), () => 1);
}

void isolateMain(MapEntry<SendPort, int> entry) {
  ReceivePort mainToIsolatePort = ReceivePort();
  entry.key.send(mainToIsolatePort.sendPort);
  mainToIsolatePort.listen((message) {
    print("from main : $message");
  });
  Future(() {
    var result = fib(entry.value);
    print("result= $result");
    entry.key.send(result);
  });
}

void test8() {
  ReceivePort isolateToMainPort = ReceivePort();
  isolateToMainPort.listen((message) {
    if (message is SendPort) {
      message.send("i sure");
    } else {
      print("from isolate : $message");
    }
  });
  Isolate.spawn(isolateMain, MapEntry(isolateToMainPort.sendPort, 40));
}

int fib(int n) {
  return n > 2 ? fib(n - 1) + fib(n - 2) : 1;
}

void test9() async {
  var result = await compute(fib, 20);
  print(result);
}

class ConverseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: RaisedButton(
            onPressed: () {
              showDialog(context: context, builder: (c) => ConverseWidget(
                content: content,
                name: "弗拉特尔",
                imageUrl: "images/ic_launcher.png",
                optionMap: {"查看更多1":(){}, "查看更多2":(){}},
              ));
            },
            child: Text("Converse"),
          ),
        ),
      ),
    );
  }
}

class ConverseWidget extends StatefulWidget {
  final String content;
  final String name;
  final String imageUrl;
  final Map<String, Function> optionMap;

  const ConverseWidget({Key key, this.content, this.name, this.imageUrl, this.optionMap}) : super(key: key);
  @override
  _ConverseWidgetState createState() => _ConverseWidgetState();
}

var content = "新生代采用复制清除算法，针对频繁创建销毁的页面控件对象，可以从内内存回收场景，尽量保证UI的流畅性"
    "新生代采用复制清除算法，针对频繁创建销毁的页面控件对象，可以从内内存回收场景，尽量保证UI的流畅性"
    "新生代采用复制清除算法，针对频繁创建销毁的页面控件对象，可以从内内存回收场景，尽量保证UI的流畅性"
    "新生代采用复制清除算法，针对频繁创建销毁的页面控件对象，可以从内内存回收场景，尽量保证UI的流畅性";

class _ConverseWidgetState extends State<ConverseWidget> {
  @override
  Widget build(BuildContext context) {
    Widget buildOption(String name, action()) {
      return GestureDetector(
        child: Text(name, style: TextStyle(color: Colors.lightBlue)),
        onTap: action,
      );
    }

    return Center(
      child: Container(
        width: 344.p,
        height: 168.p,
        child: Material(
          elevation: 4.0,
//          color: Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Positioned(
                left: 32.p,
                top: 32.p,
                child: Container(
                  height: 96.p,
                  padding: EdgeInsets.only(left: 8.p, top: 16.p, right: 8.p, bottom: 8.p),
                  child: SingleChildScrollView(child: Text(content)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.lightBlue),
                  ),
                ),
                width: 304.p,
              ),
              Positioned(
                left: 32.p,
                top: 8.p,
                child: Center(
                  child: Container(
                    width: 280.p,
                    height: 24.p,
                    padding: EdgeInsets.only(left: 30.p),
                    alignment: Alignment.centerLeft,
                    child: Text(widget.name),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.lightBlue),
                    ),
                  ),
                ),
                height: 48.p,
              ),
              Positioned(
                left: 8.p,
                top: 8.p,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.lightBlue),
                    borderRadius: BorderRadius.circular(24.p),
                  ),
                  child: Image.asset("images/ic_launcher.png", width: 48.p, height: 48.p),
                ),
              ),
              Positioned(
                left: 34.p,
                top: 136.p,
                width: 304.p,
                child: Row(children: widget.optionMap.entries.map((e) => buildOption("查看更多1", () => null)).toList()),
              )
            ],
          ),
        ),
      ),
    );
  }
}
