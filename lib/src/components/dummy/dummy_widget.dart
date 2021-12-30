import 'dart:math';

import 'package:flutter/material.dart';

class DummyWidget extends StatelessWidget {
  const DummyWidget({Key? key, this.width, this.height, required this.id}) : super(key: key);

  final double? height;
  final double? width;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Container(color: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0), child: Text("Dummy for $id"));
  }
}
