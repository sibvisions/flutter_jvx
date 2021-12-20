import 'package:flutter/material.dart';

class DummyWidget extends StatelessWidget {
  const DummyWidget({Key? key, this.width, this.height, required this.id}) : super(key: key);

  final double? height;
  final double? width;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Text("Dummy for $id");
  }
}
