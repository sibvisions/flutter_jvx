import 'package:flutter/material.dart';
import '../../model/component/label/fl_label_model.dart';

class FlLabelWidget extends StatelessWidget {
  const FlLabelWidget({Key? key, required this.model}) : super(key: key);

  final FlLabelModel model;

  @override
  Widget build(BuildContext context) {
    return Text(model.text);
  }
}
