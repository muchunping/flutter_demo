import 'package:flutter/material.dart';
import "package:xml/xml.dart" as xml;

main() {
  runApp(XmlParserDemo());
}

class XmlParserDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: SafeArea(child: XmlParserWidget()),
      ),
    );
  }
}

class XmlParserWidget extends StatefulWidget {
  @override
  _XmlParserWidgetState createState() => _XmlParserWidgetState();
}

class _XmlParserWidgetState extends State<XmlParserWidget> {
  var data;
  final String xmlPath = "xmls/herbs.xml";

  @override
  void initState() {
    super.initState();
    DefaultAssetBundle.of(context).loadStructuredData(xmlPath, (data) {
      return parseXml<Herb>(data, (e) => Herb.fromXml(e));
    }).then((e) {
      setState(() {
        data = e;
      });
    });
  }

  Widget buildItem(Herb herb) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Image.network(
          herb.url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
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
    if (data == null) {
      return Container(
        child: Center(
          child: Text("Loading..."),
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.all(30),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemBuilder: (c, i) {
        return Ink(
          decoration: BoxDecoration(border: Border.all(), color: Colors.white),
          child: InkWell(
            onTap: () {},
            splashColor: Colors.blue[400],
            child: buildItem(data[i]),
          ),
        );
      },
      itemCount: data.length,
    );
  }
}

class Herb {
  final String name;
  final String url;

  Herb(this.name, this.url);

  Herb.fromXml(xml.XmlElement element)
      : name = element.attributes.firstWhere((attribute) {
          return attribute.name.local == "name";
        }).value,
        url = element.attributes.firstWhere((attribute) {
          return attribute.name.local == "pic_url";
        }).value;
}

Future<List<E>> parseXml<E>(String data, E f(xml.XmlElement element)) {
  var list = <E>[];
  var document = xml.parse(data);
  document.children
      .where((node) => node is xml.XmlElement)
      .map<xml.XmlElement>((node) => node as xml.XmlElement)
      .forEach((element) {
    print(element.name.local);
    element.children
        .where((node) => node is xml.XmlElement)
        .map<xml.XmlElement>((node) => node as xml.XmlElement)
        .forEach((element) => list.add(f(element)));
  });
  return Future.value(list);
}
