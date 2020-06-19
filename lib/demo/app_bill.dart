import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

main() => runApp(BillApp());

class BillApp extends StatelessWidget {
  @override
  Widget build(BuildContext c) {
    return MultiProvider(
      child: MaterialApp(home: HomePage()),
      providers: [
        ChangeNotifierProvider(create: (_) => Protagonist()),
      ],
    );
  }
}

//日账单，周账单，月账单，季度账单，年账单，全部账单
class Protagonist extends ChangeNotifier {
  double income = 0.0;
  double expenditure = 0.0;
  List<Bill> billList;

  void addBill(Bill bill) {
    billList.add(bill);
    notifyListeners();
  }

  get monthIncome => billList?.fold(0, (p, e) => e.amount + p) ?? 0.0;
}

class Turnover {
  //当前余额
  //当前总支出
  //当前总收入

  get balance => 0.0;

  get datetime => bill?.dateTime ?? DateTime.now();

  //账单
  Bill bill;
}

class Bill {
  double amount = 0.0;
  Label category;
  DateTime dateTime = DateTime.now();

  Bill(this.amount) : assert(amount != 0);
}

enum Label { traffic, food, shopping, salary, collection }

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                TopSearch(),
                Expanded(
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverPadding(
                        padding: const EdgeInsets.only(
                            left: 8.0, top: 10.0, right: 8.0),
                        sliver: Head(),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        sliver: Neck(),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.only(
                            left: 8.0, bottom: 10.0, right: 8.0),
                        sliver: Body(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              child: RaisedButton(
                padding: EdgeInsets.only(
                  right: 16.0,
                  top: 8.0,
                  bottom: 8.0,
                  left: 8.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                color: Colors.green,
                child: Row(
                  children: <Widget>[
                    const SizedBox(width: 8.0),
                    Icon(Icons.add, color: Colors.white, size: 24.0),
                    const SizedBox(width: 8.0),
                    Text(
                      "记一笔",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                  ],
                ),
                onPressed: () {
                  context.read<Protagonist>().addBill(Bill(38.0));
                },
              ),
              right: 16.0,
              bottom: 16.0,
            ),
          ],
        ),
      ),
    );
  }
}

class TopSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.0,
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        children: <Widget>[
          Text(
            "我的记账本",
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
            constraints: const BoxConstraints(maxHeight: 24.0, maxWidth: 24.0),
            padding: EdgeInsets.all(0.0),
          )
        ],
      ),
    );
  }
}

const TextStyle style_1 = TextStyle(color: Colors.grey, fontSize: 12.0);

class Head extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: build2(context),
    );
  }

  build2(BuildContext context) {
    return Container(
      height: 180.0,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (c, i) {
          return PageView.builder(
            reverse: true,
            scrollDirection: Axis.vertical,
            itemBuilder: (c, i) {
              return build1(c);
            },
          );
        },
      ),
    );
  }

  build1(BuildContext context) {
    return Card(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text("本月支出", style: style_1),
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                  "￥${context.read<Protagonist>().monthIncome}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 24.0),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.remove_red_eye,
                    size: 18.0,
                  ),
                  onPressed: () {},
                )
              ],
            ),
            Row(
              children: <Widget>[
                Text.rich(
                  TextSpan(text: "本月收入 ", children: [
                    TextSpan(
                      text: "￥13000.00",
                      style: TextStyle(color: Colors.black, fontSize: 14.0),
                    ),
                  ]),
                  style: style_1,
                ),
                Spacer(),
                Text.rich(
                  TextSpan(text: "预算剩余 ", children: [
                    TextSpan(
                      text: "未设置",
                      style: TextStyle(color: Colors.black, fontSize: 14.0),
                    ),
                  ]),
                  style: style_1,
                ),
              ],
            ),
            Flexible(
              child: Center(
                child: FlatButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.insert_chart,
                      color: Colors.green,
                    ),
                    label: Text("查看图表分析")),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Neck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(left: 8.0, top: 16.0, right: 8.0, bottom: 8.0),
        child: Text("今日支持 ￥383.00  收入 ￥13000.00"),
      ),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (c, i) {
          return Card(
            child: ListTile(
              title: Text("data"),
              subtitle: Text("$i"),
            ),
          );
        },
        itemCount: 10,
      ),
    );
  }
}
