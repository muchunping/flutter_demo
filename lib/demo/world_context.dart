import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

main() => runApp(MaterialApp(home: LegendApp()));

const double maxTime = 3000.0;

class LegendApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: LegendHomePage()));
  }
}

class LegendHomePage extends StatefulWidget {
  @override
  _LegendHomePageState createState() => _LegendHomePageState();
}

class _LegendHomePageState extends State<LegendHomePage> {
  WorldContext world;

  @override
  void initState() {
    super.initState();
    world = WorldContext()..initWithFirst();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildMenu(String name, f()) {
      return Container(
        width: 64,
        height: 36,
        child: RaisedButton(
          onPressed: f,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Text(name),
        ),
      );
    }

    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(color: Colors.white, border: Border.all()),
          width: double.maxFinite,
          height: 160,
          child: Row(
            children: <Widget>[
              buildMenu("背包", () => open(context, "luggage")),
            ],
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 1)),
        Container(
          width: double.maxFinite,
          height: 48,
          decoration: BoxDecoration(color: Colors.white, border: Border.all()),
          child: Row(
            children: <Widget>[
              buildMenu("出口", () => exit(context)),
              Flexible(
                child: Center(child: Text("${world.currentScene.name}")),
                fit: FlexFit.tight,
              ),
              buildMenu("探索", () => open(context, "battle")),
            ],
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 1)),
        Flexible(
          child: Container(
            decoration:
                BoxDecoration(color: Colors.white, border: Border.all()),
            child: ListView.builder(
              itemBuilder: (c, i) {
                SystemPeople people = world.peopleList.firstWhere(
                    (e) => e.id == world.currentScene.peopleList[i]);
                return ListTile(
                  title: Text(people.name),
                  onTap: () {
                    showDialog(
                        context: c,
                        builder: (c) {
                          return SimpleDialog(
                            children: <Widget>[
                              Text(people.converse ?? "走开，别烦我"),
                              SimpleDialogOption(
                                child: Text("有什么可以帮你的？"),
                                onPressed: () {},
                              )
                            ],
                          );
                        });
                  },
                );
              },
              itemCount: world.currentScene.peopleList.length,
            ),
          ),
        ),
      ],
    );
  }

  void open(BuildContext c, String action) {
    switch (action) {
      case "luggage":
        Navigator.of(c).push(MaterialPageRoute(builder: (c) {
          return LuggagePage(luggage: world.player.luggage);
        }));
        break;
      case "battle":
        Navigator.of(c).push(MaterialPageRoute(builder: (c) {
          return BattlePage(
              intruderArray: [world.bList[0]], defenderArray: [world.player]);
        }));
        break;
    }
  }

  void exit(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text("选择"),
              children: world.currentScene.neighbor
                  .map<SimpleDialogOption>((String id) {
                var scene = world.aList.firstWhere((e) => e.id == id);
                return SimpleDialogOption(
                  child: Text("${scene.name}"),
                  onPressed: () {
                    world.currentScene = scene;
                    Navigator.pop(context);
                    setState(() {});
                  },
                );
              }).toList());
        });
  }
}

class LuggagePage extends StatelessWidget {
  final Luggage luggage;

  const LuggagePage({Key key, this.luggage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: ListView.builder(
        itemBuilder: (c, i) {
          var elementAt = luggage.itemMap.entries.elementAt(i);
          return ListTile(
            title: Text(elementAt.key.name),
            subtitle: Text("数量: ${elementAt.value}"),
            onTap: () {},
          );
        },
        itemCount: luggage.itemCount,
      )),
    );
  }
}

class BattlePage extends StatelessWidget {
  final List<Fighter> intruderArray;
  final List<Fighter> defenderArray;

  const BattlePage({Key key, this.intruderArray, this.defenderArray})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Playground playground = Playground()
      ..setupIntruder(intruderArray)
      ..setupDefender(defenderArray);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            width: 360,
            height: 720,
            child: PlaygroundWidget(playground: playground),
          ),
        ),
      ),
    );
  }
}

class PlaygroundWidget extends StatefulWidget {
  final Playground playground;

  const PlaygroundWidget({Key key, this.playground}) : super(key: key);

  @override
  _PlaygroundWidgetState createState() => _PlaygroundWidgetState();
}

class _PlaygroundWidgetState extends State<PlaygroundWidget> {
  double arrayWidth = 320;
  double arrayHeight = 320;

  @override
  void initState() {
    super.initState();
    widget.playground.computeSlotPosition(arrayWidth, arrayHeight);
    WidgetsBinding.instance.addPostFrameCallback((d) {
      setState(() {
        widget.playground.play();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: arrayWidth,
            height: arrayHeight,
            decoration: _GridDecoration(
              widget.playground.topSlotPositionMap.values,
              backgroundColor: Color(0x33FF0000),
            ),
            child: ArrayWidget(
              array: widget.playground.topArray,
              slotMap: widget.playground.topSlotPositionMap,
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            width: 360,
            height: 80,
            color: Colors.white,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: arrayWidth,
            height: arrayHeight,
            decoration: _GridDecoration(
              widget.playground.bottomSlotPositionMap.values,
              backgroundColor: Color(0x33FF00FF),
            ),
            child: ArrayWidget(
              array: widget.playground.bottomArray,
              slotMap: widget.playground.bottomSlotPositionMap,
            ),
          ),
        )
      ],
    );
  }
}

class ArrayWidget extends StatefulWidget {
  final List<Fighting> array;
  final Map<ArraySlotPosition, Rect> slotMap;

  const ArrayWidget({Key key, this.array, this.slotMap}) : super(key: key);

  @override
  _ArrayWidgetState createState() => _ArrayWidgetState();
}

class _ArrayWidgetState extends State<ArrayWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((d) {
      Offset offset =
          (context.findRenderObject() as RenderBox).localToGlobal(Offset.zero);
      widget.slotMap.values.forEach((e) => e.translate(offset.dx, offset.dy));
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: widget.array.map(
        (e) {
          Rect rect = widget.slotMap[e.position];
          return Positioned(
            left: rect.left,
            top: rect.top,
            child: Container(
              width: rect.width,
              height: rect.height,
              alignment: Alignment.center,
              child: BallWidget(fighting: e),
            ),
          );
        },
      ).toList(),
    );
  }
}

class BallWidget extends StatefulWidget {
  final Fighting fighting;

  const BallWidget({Key key, this.fighting}) : super(key: key);

  @override
  _BallWidgetState createState() => _BallWidgetState();
}

class _BallWidgetState extends State<BallWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _positionController;
  Animation<Offset> _positionFactor;

  @override
  void initState() {
    super.initState();
    _positionController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    widget.fighting.notify = play;
    widget.fighting.rect = () {
      var box = context.findRenderObject() as RenderBox;
      Offset offset = box.localToGlobal(Offset.zero);
      print("${widget.fighting.fighter} offset = $offset");
      return box.paintBounds.translate(offset.dx, offset.dy);
    };
  }

  void play(Rect target) {
    var box = context.findRenderObject() as RenderBox;
    Offset o = box.localToGlobal(Offset.zero);
    var local = box.paintBounds.translate(o.dx, o.dy);
    print("local= $local");
    print("target= $target");
    var offset = local.center - target.center;
    print("offset= $offset");
    var end = Offset(-offset.dx / local.width, -offset.dy / local.height);
    print("end= $end");
    _positionFactor = _positionController.drive(
        Tween(begin: Offset(0, 0), end: end)
            .chain(CurveTween(curve: Curves.easeInQuart)));
    setState(() {});
    _positionController
        .animateTo(1.5)
        .whenComplete(() => _positionController.animateTo(0.0));
  }

  @override
  Widget build(BuildContext context) {
    var container = Container(
      width: 64,
      height: 64,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(18.0))),
      alignment: Alignment.center,
      child: Text(widget.fighting.fighter.duration.toString()),
    );
    return _positionFactor != null
        ? SlideTransition(
            position: _positionFactor,
            child: container,
          )
        : container;
  }
}

class _GridDecoration extends Decoration {
  final Color backgroundColor;
  final Iterable<Rect> slotPositions;

  _GridDecoration(this.slotPositions, {this.backgroundColor});

  @override
  BoxPainter createBoxPainter([onChanged]) {
    return _GridBoxPainter(slotPositions, backgroundColor);
  }
}

class _GridBoxPainter extends BoxPainter {
  final Color backgroundColor;
  final Iterable<Rect> slotPositions;

  _GridBoxPainter(this.slotPositions, this.backgroundColor);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = offset & configuration.size;
    var backgroundPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = backgroundColor;
    canvas.drawRect(rect, backgroundPaint);
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white;
    canvas.drawRect(rect, paint);
    slotPositions.forEach((e) {
      canvas.drawRect(e.translate(offset.dx, offset.dy), paint);
    });
  }
}

/// 关于ID:
/// 场景ID以A开头，比如A001表示新手村
/// 敌人ID以B开头，比如B001表示野狗
/// 装备ID以C开头，比如C001表示乌木剑
/// 消耗品ID以D开头，比如D001表示强效生命药水
/// 材料ID以E开头，比如E001表示干树枝
/// 任务物品ID以F开头，比如F001表示奇怪的石头
/// 任务ID以G开头，比如G001表示"奇怪的石头"任务
/// 系统人物ID以H开头，比如H001表示新手村武器店老板
class WorldContext {
  List<Scene> aList = [
    Scene("A001", "新手村")
      ..neighbor = ["1002"]
      ..peopleList = ["1001", "1002"],
    Scene("1002", "毒蛇山谷")
      ..neighbor = ["1001"]
      ..peopleList = ["1003"],
  ];
  List<Enemy> bList = [
    Enemy("1001", "野狗")
      ..level = 1
      ..attackPoint = 5
      ..defensePoint = 1
      ..healthPoint = 20
      ..speedPoint = 50.2,
  ];
  List<EquipmentModel> cList = [
    EquipmentModel("10001", "圣剑")
      ..effectList = [
        Effect()
          ..type = EffectType.IncreaseAP
          ..value = 50
      ]
  ];
  List<Medicine> medicineList = [
    Medicine("1001", "强效生命药水")
      ..effect = (Effect()
        ..type = EffectType.RestoreHP
        ..value = 100)
  ];
  List<TaskItem> taskItemList = [
    TaskItem("1001", "奇怪的石头")..description = "一块黑乎乎的石头，有一种神秘的气息",
  ];
  List<SystemPeople> peopleList = [
    SystemPeople("1001", "武馆老版"),
    SystemPeople("1002", "书店老版"),
    SystemPeople("1003", "猎人")..converse = "嘘...小声一点，我正在捕猎，有事快说",
  ];
  List<Task> taskList = [
    Task()
      ..startPeopleId = "1001"
      ..endPeopleId = "1003"
      ..converse = "我在打猎的时候捡到了一个[1001]，你帮我带给[1003]，让他鉴别一下"
      ..rewardList = [Reward("exp", 1000), Reward("money", 500)],
  ];

  Player player;
  Scene currentScene;
  int turnCount = 0;

  WorldContext() {
    initWithFirst();
  }

  void initWithFirst() {
    currentScene = aList.firstWhere((e) => e.id == "A001");
    Luggage luggage = Luggage()
      ..itemMap = {
        medicineList[0]: 20,
        Equipment("0001", cList[0]): 1,
      };
    WearEquipment wear = WearEquipment();
    player = Player("江湖小虾米")
      ..level = 1
      ..healthPoint = 100
      ..attackPoint = 10
      ..defensePoint = 0
      ..speedPoint = 100.1
      ..luggage = luggage
      ..wear = wear;
  }

  void play() {
    print("-------- 第${turnCount++}回合 --------");
  }
}

class Playground {
  Map<ArraySlotPosition, Rect> topSlotPositionMap = Map();
  Map<ArraySlotPosition, Rect> bottomSlotPositionMap = Map();
  List<Fighting> topArray = List();
  List<Fighting> bottomArray = List();
  static const int row = 3;
  static const int column = 3;

  computeSlotPosition(double arrayWidth, double arrayHeight) {
    var width = arrayWidth / (row + 1);
    var height = arrayHeight / (column + 1);
    var spaceH = width / (row + 1);
    var spaceV = height / (column + 1);
    var firstRect = Rect.fromLTWH(spaceH, spaceV, width, height);
    if (row % 2 == 0) firstRect = firstRect.translate(spaceH / 2, 0);
    if (column % 2 == 0) firstRect = firstRect.translate(0, spaceV / 2);
    for (int i = 0; i < column; i++) {
      double dy = (height + spaceV) * i;
      for (int j = 0; j < row; j++) {
        double dx = (width + spaceH) * j;
        var rect = firstRect.translate(dx, dy);
        topSlotPositionMap[ArraySlotPosition(column - i - 1, j)] = rect;
        bottomSlotPositionMap[ArraySlotPosition(i, j)] = rect;
      }
    }
  }

  void setupIntruder(List<Fighter> intruderArray) {
    bottomArray = intruderArray.map((e) => Fighting(e, true)).toList();
    _setupPosition(bottomArray);
  }

  void setupDefender(List<Fighter> defenderArray) {
    topArray = defenderArray.map((e) => Fighting(e, false)).toList();
    _setupPosition(topArray);
  }

  void _setupPosition(Iterable<Fighting> iterable) {
    int i = 0;
    int j = 0;
    iterable.forEach((e) {
      e.position = ArraySlotPosition(i, j);
      j++;
      if (j == Playground.row) {
        j = 0;
        i++;
      }
    });
  }

  Future<void> play() async {
    double time = 0;
    int count = 0;
    assert(topArray.isNotEmpty && bottomArray.isNotEmpty);
    for (;;) {
      await new Future.delayed(const Duration(milliseconds: 3000));
      print("----- ${count++} -----");
      Fighting nextBall;
      var allArray = topArray.followedBy(bottomArray);
      allArray.forEach((e) {
        if (e.time < (nextBall?.time ?? double.infinity)) nextBall = e;
      });
      final deltaTime = nextBall.time;
      time += deltaTime;
      print("当前时序 = $time");
      allArray.forEach((e) {
        e.time -= deltaTime;
        if (e.time <= 0) e.time += e.fighter.duration;
      });
      var enemy = (nextBall.isIntruder ? topArray : bottomArray)
          .firstWhere((e) => true);
      nextBall.play(enemy);
      if (time > maxTime) {
        print("over time!");
        return;
      }
    }
  }
}

class Player extends Fighter {
  int level;
  List<Skill> learnedSkillList;
  WearEquipment wear;
  Luggage luggage;

  Player(String name) : super(name);
}

class Fighter {
  final String name;
  double healthPoint;
  double attackPoint;
  double defensePoint;
  double speedPoint;

  Fighter(this.name);

  get duration => 1000 / speedPoint;
}

class WearEquipment {
  Equipment head;
  Equipment neck;
  Equipment body;
  Equipment hand;
  Equipment leftWrist;
  Equipment rightWrist;
  Equipment leftFinger;
  Equipment rightFinger;
  Equipment foot;

  get effect {
    return List<Effect>();
  }
}

class Equipment extends Item {
  EquipmentModel model;
  String id;

  Equipment(this.id, this.model) : super(id, model.name);
}

class EquipmentModel extends Item {
  List<Effect> effectList;

  EquipmentModel(String id, String name) : super(id, name);
}

abstract class Item {
  final String id;
  final String name;

  Item(this.id, this.name);
}

class Skill {}

class Luggage {
  Map<Item, int> itemMap = Map();

  get itemCount => itemMap.length;
}

class Scene {
  final String id;
  final String name;
  bool isVisible;
  List<String> neighbor;
  List<String> peopleList;

  Scene(this.id, this.name);
}

class Enemy extends Fighter {
  final String id;
  int level;

  Enemy(this.id, String name) : super(name);
}

class Medicine extends Item {
  Effect effect;

  Medicine(String id, String name) : super(id, name);
}

class Effect {
  EffectType type;
  double value;
}

enum EffectType { IncreaseMaxHP, DecreaseMaxHP, RestoreHP, IncreaseAP }

class TaskItem extends Item {
  String description;

  TaskItem(String id, String name) : super(id, name);
}

class Material {}

class SystemPeople {
  final String id;
  final String name;
  String converse;

  SystemPeople(this.id, this.name);
}

class Reward {
  final String id;
  final double value;

  Reward(this.id, this.value);
}

class Task {
  List<TaskCondition> conditionList;
  TaskType type;
  List<Reward> rewardList;
  String startPeopleId;
  String endPeopleId;
  String converse;
}

class TaskGroup {}

enum TaskType { Collect, SendLetter }

class TaskCondition {
  ConditionType type;
  double value;
}

enum ConditionType { LevelMax, LevelMin, TaskComplete }

class ArraySlotPosition {
  final int rowIndex;
  final int columnIndex;

  ArraySlotPosition(this.rowIndex, this.columnIndex);

  @override
  bool operator ==(other) {
    return other is ArraySlotPosition &&
        other.columnIndex == this.columnIndex &&
        other.rowIndex == this.rowIndex;
  }

  @override
  int get hashCode => hashValues(columnIndex, rowIndex);
}

typedef PlayNotify = void Function(Rect m);
typedef GlobalRect = Rect Function();

class Fighting {
  final Fighter fighter;
  final bool isIntruder;
  ArraySlotPosition position;
  double time;
  PlayNotify notify;
  GlobalRect rect;

  Fighting(this.fighter, this.isIntruder) : time = fighter.duration;

  void play(Fighting enemy) {
    notify?.call(enemy.rect?.call());
    print("$this action");
  }

  @override
  String toString() {
    return 'RunningBall{ball: $fighter, time: $time}';
  }
}
