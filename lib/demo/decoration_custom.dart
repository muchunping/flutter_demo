import 'package:flutter/material.dart';

main() {
  runApp(MaterialApp(home: DecorationApp()));
}

class DecorationApp extends StatelessWidget {
  final Pretender dataObject = Pretender("东方不败", 4, intensity: 3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: PretenderWidget(dataObject: dataObject),
        ),
      ),
    );
  }
}

class PretenderWidget extends StatelessWidget {
  final Pretender dataObject;

  const PretenderWidget({Key key, this.dataObject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: _CustomDecoration(dataObject),
      alignment: Alignment.center,
      child: NameText(object: dataObject),
    );
  }
}

class Pretender {
  final String name;
  int intensity;
  final int star;

  Pretender(this.name, this.star, {this.intensity = 1})
      : assert(name.length > 1 && name.length < 5);
}

class NameText extends StatelessWidget {
  final String text;
  final Color color;

  NameText({Key key, Pretender object})
      : text = object.name,
        color = _getColor(object.star),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle leftStyle = TextStyle(fontSize: 24, height: 1.0, color: color);
    TextStyle rightStyle = leftStyle.copyWith(fontSize: 14);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(text.substring(0, 1), style: leftStyle),
            Text(text.substring(1, 2), style: leftStyle),
          ],
        ),
        if (text.length > 2)
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(text.substring(2, 3), style: rightStyle),
              if (text.length > 3)
                Text(text.substring(3, 4), style: rightStyle),
              Padding(padding: EdgeInsets.only(bottom: 10.0))
            ],
          )
      ],
    );
  }

  static _getColor(int star) {
    switch (star) {
      case 1:
        return Colors.greenAccent;
      case 2:
        return Colors.lightBlueAccent;
      case 3:
        return Colors.purpleAccent;
      case 4:
        return Colors.redAccent;
      default:
        return Colors.amber;
    }
  }
}

class _CustomDecoration extends Decoration {
  final Pretender dataObject;

  _CustomDecoration(this.dataObject);

  @override
  BoxPainter createBoxPainter([onChanged]) {
    return _CustomBoxPainter(dataObject);
  }
}

class _CustomBoxPainter extends BoxPainter {
  final Pretender dataObject;

  _CustomBoxPainter(this.dataObject);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = offset & configuration.size;
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.amber;
    if (dataObject.intensity >= 1) {
      canvas.drawRect(rect, paint);
    }
    if (dataObject.intensity >= 2) {
      Rect sRect = Rect.fromCenter(
          center: rect.center,
          width: rect.width * 0.95,
          height: rect.height * 0.95);
      canvas.drawRRect(
          RRect.fromRectAndRadius(sRect, Radius.circular(8)), paint);
    }
    if (dataObject.intensity >= 3) {
      canvas.drawCircle(rect.center, rect.width * 0.45, paint);
    }
  }
}
