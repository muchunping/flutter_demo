import 'dart:typed_data';

import 'package:flutter/material.dart';

class LineChartDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var data = LineChartData()
      ..data = [
        Offset(100, 500),
        Offset(200, 150),
        Offset(300, 50),
        Offset(400, 50),
        Offset(500, 100),
      ];
    return Scaffold(
      appBar: AppBar(
        title: Text("折线图"),
      ),
      body: Container(
        color: Colors.yellowAccent,
        alignment: Alignment.center,
        child: LineChart(data),
      ),
    );
  }
}

class LineChart extends StatefulWidget {
  final LineChartData data;

  @override
  _LineChartState createState() => _LineChartState();

  LineChart(this.data);
}

class _LineChartState extends State<LineChart> {
  Offset offset = Offset.zero;
  Offset start;
  double scale = 1.0;
  double lastScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (c, bc) {
      final Size size = Size(bc.maxWidth, bc.maxHeight / 2);
      return GestureDetector(
        onScaleStart: (d) {
          start = d.focalPoint;
          print("onScaleStart: $d");
        },
        onScaleUpdate: (d) {
          setState(() {
            if ((d.scale - 1).abs() > d.rotation.abs()) {
              scale = lastScale * d.scale;
            } else if (d.rotation != 0) {
              //rotate
            } else {
              offset = offset.translate(
                  d.focalPoint.dx - start.dx, d.focalPoint.dy - start.dy);
              start = d.focalPoint;
            }
          });
          print("onScaleUpdate: $d");
        },
        onScaleEnd: (d) {
          lastScale = scale;
          print("onScaleEnd: $d");
        },
        child: CustomPaint(
          painter: _LineChartPainter(widget.data, offset: offset, scale: scale),
          size: size,
        ),
      );
    });
  }
}

class _LineChartPainter extends CustomPainter {
  LineChartData data;

  // 手势偏移量
  Offset offset;

  // 每多少像素为一个刻度
  double scratchSpace;

  // 每多少个刻度为一个大刻度
  int bigScratchSpace;

  // 手势缩放比例
  double scale;

  _LineChartPainter(
    this.data, {
    this.offset,
    this.scale = 1.0,
    double scratchSpace = 12.0,
    this.bigScratchSpace = 5,
  }) : this.scratchSpace = scratchSpace * scale;

  // 计算第一个大刻度的位置， dx为手势滑动偏移量
  // 向左滑动，dx减小，为负数，向右滑动，dx增大，为正数
  // 向上滑动，dx减小，为负数，向下滑动，dx增大，为正数
  // 由于坐标系向右为增大，向上为增大，故，左右滑动dx变化与坐标系方向相反，需要取相反数
  int getBigScratchOffset(double dx) {
    print("总偏移量为 $dx");
    //小刻度偏移量
    int small = dx % (scratchSpace * bigScratchSpace) ~/ scratchSpace;
    print("小刻度偏移量为 $small");
    double pixel = dx % (scratchSpace * bigScratchSpace) % scratchSpace;
    print("像素偏移量为 $pixel");
    if (pixel == 0) {
      return (bigScratchSpace - small) % bigScratchSpace;
    }
    return bigScratchSpace - small - 1;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Rect clipRect = Rect.fromCircle(
        center: size.center(Offset.zero), radius: size.width / 2 - 10);
    canvas.clipRect(clipRect);
    final borderPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(clipRect, borderPaint);
    borderPaint..color = Colors.black;

    scratchSpace = scale * scratchSpace;

    canvas.drawLine(clipRect.bottomLeft, clipRect.bottomRight, borderPaint);
    var scratchEnd = clipRect.left + offset.dx % scratchSpace;
    // 向左滑动，dx减小，为负数，向右滑动，dx增大，为正数
    // 由于坐标系向左为减小，左滑dx减小而x轴增大，与其相反，需要取相反数
    var bigScratchOffset = getBigScratchOffset(-offset.dx);
    while (scratchEnd <= clipRect.right) {
      var scratchIndex = (scratchEnd - clipRect.left) ~/ scratchSpace;
      var isBig = scratchIndex % bigScratchSpace == bigScratchOffset;
      var p1 = Offset(scratchEnd, clipRect.bottom + 1.0);
      var p2 = Offset(scratchEnd, clipRect.bottom - (isBig ? 10.0 : 6.0));
      canvas.drawLine(p1, p2, borderPaint);
      scratchEnd += scratchSpace;
    }

    canvas.drawLine(clipRect.bottomLeft, clipRect.topLeft, borderPaint);
    scratchEnd = clipRect.bottom + offset.dy % scratchSpace;
    bigScratchOffset = getBigScratchOffset(offset.dy);
    while (scratchEnd >= clipRect.top) {
      var scratchIndex = (clipRect.bottom - scratchEnd) ~/ scratchSpace;
      var isBig = scratchIndex % bigScratchSpace == bigScratchOffset;
      var p1 = Offset(clipRect.left, scratchEnd);
      var p2 = Offset(clipRect.left + (isBig ? 10.0 : 6.0), scratchEnd);
      canvas.drawLine(p1, p2, borderPaint);
      scratchEnd -= scratchSpace;
    }

    Path path = Path();
    path.moveTo(clipRect.left + offset.dx, clipRect.bottom + offset.dy);
    data.data.forEach((e) {
      path.lineTo(e.dx * scale + clipRect.left + offset.dx,
          clipRect.bottom - e.dy * scale + offset.dy);
    });
    borderPaint..color = Colors.greenAccent;
    canvas.drawPath(path, borderPaint);

    var i = 0;
    ["scale: $scale", "dx: ${offset.dx}", "dy: ${offset.dy}"].forEach((text) {
      const TextStyle style = TextStyle(color: Colors.red);
      var textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      var translate = clipRect.topRight
          .translate(-textPainter.width - 4, 4 + textPainter.height * i);
      textPainter.paint(canvas, translate);
      i++;
    });
  }

  @override
  bool shouldRepaint(_LineChartPainter old) {
    return old.offset != this.offset || old.data != this.data;
  }
}

class LineChartData {
  List<Offset> data;
  double dimensionX, dimensionY;
}
