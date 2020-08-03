import 'package:flutter/material.dart';

main() {
  runApp(MaterialApp(home: StreetPage()));
}

class StreetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: StreetWidget()));
  }
}

class StreetWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          child: Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            color: Colors.lightBlueAccent,
            child: Text("武器"),
          ),
          left: 10,
          top: 10,
        ),
        Positioned(
          child: Container(
            width: 64,
            height: 64,
            color: Colors.lightBlueAccent,
            alignment: Alignment.center,
            child: Text("头盔"),
          ),
          right: 10,
          top: 10,
        ),
        Positioned(
          child: Container(
            width: 64,
            height: 64,
            color: Colors.lightBlueAccent,
            alignment: Alignment.center,
            child: Text("项链"),
          ),
          left: 10,
          top: 84,
        ),
      ],
    );
  }
}
