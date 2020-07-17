import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'demo/app_bill.dart';
import 'demo/change_notifier.dart';
import 'demo/conway_life.dart';
import 'demo/decoration_custom.dart';
import 'demo/flight_ball.dart';
import 'demo/guillotine_menu.dart';
import 'demo/hero_animation.dart';
import 'demo/jumper.dart';
import 'demo/line_chart.dart';
import 'demo/platform_communicate.dart';
import 'demo/refresh_indicator.dart';
import 'demo/route_animation.dart';
import 'demo/running_balls.dart';
import 'demo/spring_ball.dart';
import 'demo/todo_drawer.dart';
import 'demo/xml_parser.dart';

void main() => runApp(MyApp());
var routes = {
  "guillotine_menu": (c) => new GuillotineMenuDemo(),
  "todo_drawer": (c) => new TodoDrawerDemo(),
  "xml_parser": (c) => new XmlParserDemo(),
  "route_animation": (c) => new RouteAnimationDemo(),
  "hero_animation": (c) => new HeroAnimationDemo(),
  "line_chart": (c) => new LineChartDemo(),
  "change_notifier": (c) => new ChangeNotifierDemo(),
  "platform_communicate": (c) => new PlatformCommunicateDemo(),
  "app_bill": (c) => new BillApp(),
  "jump_ball": (c) => new JumperApp(),
  "spring_ball": (c) => new SpringBallApp(),
  "decoration_custom": (c) => new DecorationApp(),
  "refresh_indicator": (c) => new RefreshIndicatorDemo(),
  "flight_ball": (c) => new FightBallApp(),
  "running_balls": (c) => new RunningBallApp(),
  "conway_life": (c) => new ConwayLifeApp(),
};

//全局唯一实例，防止下次进入页面重复创建
const platform = const MethodChannel('mu.demo');

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 为了解决首次返回不生效的问题
    platform.setMethodCallHandler((call) => null);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      routes: routes,
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List data = routes.keys.toList(growable: false);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: GridView.builder(
          padding: EdgeInsets.all(30),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemBuilder: (c, i) {
            return Ink(
              decoration: BoxDecoration(border: Border.all()),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(data[i]);
                },
                splashColor: Colors.blue[400],
                child: Center(
                  child: Text(data[i]),
                ),
              ),
            );
          },
          itemCount: data.length,
        ),
      ),
    );
  }
}
