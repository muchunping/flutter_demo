import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HeroAnimationDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _Home(),
      routes: {
        "item_detail": (c) => _ItemDetailPage(),
      },
    );
  }
}

class _Home extends StatelessWidget {
  Widget buildItem(Herb herb) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Hero(
            key: Key(herb.url),
            tag: herb.url,
            child: Image.network(
              herb.url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            color: Colors.white70,
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(herb.name, style: TextStyle(color: Colors.black)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var data = [
      Herb("当归",
          "https://bkimg.cdn.bcebos.com/pic/0b55b319ebc4b745e1f3da1accfc1e178a821552?x-bce-process=image/resize,m_lfit,w_220,h_220,limit_1"),
      Herb("薰衣草",
          "https://cdn.pixabay.com/photo/2016/01/02/00/42/lavender-1117275__480.jpg"),
    ];
    return Scaffold(
      body: SafeArea(
        child: GridView.builder(
          padding: EdgeInsets.all(30),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemBuilder: (c, i) {
            return GestureDetector(
              onTap: () {
                Navigator.of(c).push(
                  PageRouteBuilder(
                    settings: RouteSettings().copyWith(arguments: data[i]),
                    pageBuilder: (c, a, b) {
                      return _ItemDetailPage();
                    },
                    transitionsBuilder: (c, a, b, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(a),
                        child:
                            child, // child is the value returned by pageBuilder
                      );
                    },
                  ),
                );
              },
              child: buildItem(data[i]),
            );
          },
          itemCount: data.length,
        ),
      ),
    );
  }
}

class _ItemDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Herb herb = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(herb.name),
      ),
      body: Container(
        child: Hero(
            tag: herb.url,
            child: Image.network(
              herb.url,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            )),
        color: Colors.lightGreen,
      ),
    );
  }
}

class Herb {
  final String name;
  final String url;

  Herb(this.name, this.url);
}
