import 'dart:async';
import 'dart:io';

import 'dart:isolate';

import 'package:flutter/foundation.dart';

main() {
  print("main#1");
  test8();
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
  Future((){
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
