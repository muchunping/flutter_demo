import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

main() {
  runApp(MaterialApp(home: RefreshIndicatorDemo()));
}

var data = [
  "Lina",
  "Lion",
  "Pack",
  "Tiny",
  "Tinker",
];
class RefreshIndicatorDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("下拉刷新")),
      body: MyRefreshIndicator(
          child: ListView.builder(
            padding: EdgeInsets.all(20.0),
            itemBuilder: (c, i) {
              return Card(
                child: ListTile(
                  onTap: () {},
                  title: Text(data[i]),
                  trailing: Text(
                    "查看详情",
                    style: TextStyle(color: Colors.lightBlue, fontSize: 12),
                  ),
                ),
              );
            },
            itemCount: data.length,
          ),
          onRefresh: () async {
            await Future.delayed(Duration(seconds: 5));
          }),
    );
  }
}

enum _RefreshIndicatorMode {
  drag, //拖拽以过度滚动
  inertia, //可滚动部件惯性滚动
  finger, //可滚动部件手指滑动
  refresh, //处理花心事件中
  cancel, //取消
  done, //已完成
}

class MyRefreshIndicator extends StatefulWidget {
  final Widget child;
  final double displacement;
  final RefreshCallback onRefresh;
  final Color color;
  final Color backgroundColor;
  final ScrollNotificationPredicate notificationPredicate;
  final double strokeWidth;

  const MyRefreshIndicator(
      {Key key,
      @required this.child,
      this.displacement = 40.0,
      @required this.onRefresh,
      this.color,
      this.backgroundColor,
      this.notificationPredicate = defaultScrollNotificationPredicate,
      this.strokeWidth = 2.0})
      : super(key: key);

  @override
  _RefreshIndicatorState createState() {
    return _RefreshIndicatorState();
  }
}

class _RefreshIndicatorState extends State<MyRefreshIndicator>
    with TickerProviderStateMixin<MyRefreshIndicator> {
  AnimationController _positionController;
  Animation<double> _positionFactor;
  double _dragOffset = 0.0;
  _RefreshIndicatorMode _mode;

  static final Animatable<double> _kDragSizeFactorLimitTween =
      Tween<double>(begin: 0.0, end: 2.0);

  @override
  void initState() {
    super.initState();
    _positionController = AnimationController(vsync: this);
    _positionFactor = _positionController.drive(_kDragSizeFactorLimitTween);
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) {
      return false;
    }
    print("_handleScrollNotification($notification)");
    if (notification is ScrollStartNotification) {
      if (_mode != _RefreshIndicatorMode.refresh && _mode != null) {
        _dragOffset = 0.0;
        _positionController.value = 0.0;
        setState(() {
          _mode = null;
        });
      }
    } else if (notification is OverscrollNotification) {
      if (_mode == null ||
          _mode == _RefreshIndicatorMode.finger ||
          _mode == _RefreshIndicatorMode.drag) {
        _dragOffset -= notification.overscroll;
        _positionController.value = (_dragOffset / 128).clamp(0.0, 1.0);
        if (_positionController.value >= 1.0) {
          if (_mode != _RefreshIndicatorMode.refresh) {
            _mode = _RefreshIndicatorMode.refresh;
            final Future<void> refreshResult = widget.onRefresh();
            refreshResult.whenComplete(() {
              if (mounted && _mode == _RefreshIndicatorMode.refresh) {
                _dismiss(_RefreshIndicatorMode.done);
              }
            });
            setState(() {});
          }
        } else if (_mode != _RefreshIndicatorMode.drag) {
          _mode = _RefreshIndicatorMode.drag;
          setState(() {});
        }
      }
    } else if (notification is ScrollUpdateNotification) {
      if (_mode != _RefreshIndicatorMode.refresh) {
        if (notification.dragDetails != null) {
          if (_mode != _RefreshIndicatorMode.finger) {
            _mode = _RefreshIndicatorMode.finger;
            setState(() {});
          }
        } else {
          if (_mode != _RefreshIndicatorMode.inertia) {
            _mode = _RefreshIndicatorMode.inertia;
            setState(() {});
          }
        }
      }
    } else if (notification is ScrollEndNotification) {
      if (_mode == _RefreshIndicatorMode.drag) {
        _dismiss(_RefreshIndicatorMode.cancel);
      }
    }
    return false;
  }

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    print("_handleGlowNotification($notification)");
    if (_mode != _RefreshIndicatorMode.inertia) {
      notification.disallowGlow();
      return true;
    }
    return false;
  }

  Future<void> _dismiss(_RefreshIndicatorMode newMode) async {
    _mode = newMode;
    setState(() {});
    await _positionController.animateTo(0.0,
        duration: Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    final child = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        child: widget.child,
        onNotification: _handleGlowNotification,
      ),
    );
    print("_mode=$_mode");
    return Stack(
      children: <Widget>[
        child,
        if (_mode == _RefreshIndicatorMode.drag ||
            _mode == _RefreshIndicatorMode.refresh)
          Positioned(
            left: 0.0,
            right: 0.0,
            top: 0.0,
            child: SizeTransition(
              axisAlignment: 1.0,
              sizeFactor: _positionFactor, // this is what brings it down
              child: Container(
                alignment: Alignment.center,
                child: AnimatedBuilder(
                  animation: _positionController,
                  builder: (_, c) {
                    return RefreshProgressIndicator(
                      value: _mode == _RefreshIndicatorMode.refresh
                          ? null
                          : _positionController.value,
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }
}
