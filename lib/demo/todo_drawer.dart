import 'package:flutter/material.dart';

main() => runApp(TodoDrawerDemo());

class TodoDrawerDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text("Title")),
          body: Container(
            color: Colors.white,
            child: Center(
              child: Text("Body"),
            ),
          ),
          drawer: Drawer(
            child: TodoDrawer(),
          ),
        ),
      ),
    );
  }
}

class TodoDrawer extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  Widget buildRow(IconData icon, String text, int num) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: <Widget>[
          Icon(icon),
          Padding(padding: EdgeInsets.only(left: 8.0)),
          Text(text),
          Spacer(),
          Text(num.toString()),
          Padding(padding: EdgeInsets.only(left: 8.0)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _DrawerHeader(),
        buildRow(Icons.android, "Android", 1),
        buildRow(Icons.info_outline, "Outline", 2),
        buildRow(Icons.info, "Info", 2),
        buildRow(Icons.offline_bolt, "Bolt", 2),
        Padding(padding: EdgeInsets.only(top: 16.0)),
        Expanded(child: TabLayout()),
      ],
    );
  }
}

class _DrawerHeader extends StatefulWidget {
  @override
  State<_DrawerHeader> createState() => _DrawerHeaderState();
}

class _DrawerHeaderState extends State<_DrawerHeader> {
  final TextEditingController _controller = TextEditingController();
  bool search = false;
  FocusNode _node = FocusNode();

  @override
  void initState() {
    super.initState();
    _node.addListener(() {
      if (!_node.hasFocus) {
        search = false;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildMain() {
    if (search) {
      return TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: "Search",
        ),
        autofocus: true,
        focusNode: _node,
        controller: _controller,
      );
    } else {
      return Row(
        children: <Widget>[
          ClipOval(
            child: Image.network(
              "https://pic2.zhimg.com/v2-639b49f2f6578eabddc458b84eb3c6a1.jpg",
              width: 48.0,
              height: 48.0,
              fit: BoxFit.cover,
            ),
          ),
          Padding(padding: EdgeInsets.only(left: 8.0)),
          Text("牟乘风"),
          Spacer(),
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                search = true;
                setState(() {});
              }),
          IconButton(icon: Icon(Icons.alarm), onPressed: () {})
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 40.0, left: 16.0, right: 8.0, bottom: 16.0),
      child: buildMain(),
    );
  }
}

class TabLayout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TabLayoutState();
}

class TabLayoutState extends State<TabLayout>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    var edgeInsets = EdgeInsets.symmetric(vertical: 10.0);
    return Column(
      children: <Widget>[
        TabBar(
          tabs: [
            Padding(
              padding: edgeInsets,
              child: Text("中国", style: TextStyle(color: Colors.black)),
            ),
            Padding(
              padding: edgeInsets,
              child: Text("日本", style: TextStyle(color: Colors.black)),
            ),
            Padding(
              padding: edgeInsets,
              child: Text("俄罗斯", style: TextStyle(color: Colors.black)),
            )
          ],
          controller: _controller,
        ),
        Expanded(
            child: TabBarView(
          children: [
            Container(
              color: Colors.lime,
              child: Center(
                child: Text("中国"),
              ),
            ),
            Container(
              color: Colors.lime,
              child: Center(
                child: Text("日本"),
              ),
            ),
            Container(
              color: Colors.lime,
              child: Center(
                child: Text("俄罗斯"),
              ),
            ),
          ],
          controller: _controller,
        )),
      ],
    );
  }
}
