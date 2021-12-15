import 'package:flutter/material.dart';

class DummyWidget extends StatelessWidget {
  const DummyWidget({Key? key, this.width, this.height}) : super(key: key);

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return(SizedBox(
      height: height,
      width: width,
      child: const Text("Dummy"),
    ));
  }
}
