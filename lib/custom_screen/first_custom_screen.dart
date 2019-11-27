import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FirstCustomScreen extends StatefulWidget {
  @override
  _FirstCustomScreenState createState() => _FirstCustomScreenState();
}

class _FirstCustomScreenState extends State<FirstCustomScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('First Custom Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('1'),
            Text('2'),
            Text('3')
          ],
        ),
      ),
    );
  }
}