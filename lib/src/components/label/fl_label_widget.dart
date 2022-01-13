import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/layout/alignments.dart';
import '../../model/component/label/fl_label_model.dart';

class FlLabelWidget extends StatelessWidget {
  const FlLabelWidget({Key? key, required this.model}) : super(key: key);

  final FlLabelModel model;

  @override
  Widget build(BuildContext context) {
    return Text(
      model.text,
      textAlign: HorizontalAlignmentE.toTextAlign(model.horizontalAlignment),
      style: TextStyle(
        backgroundColor: model.background,
        color: model.foreground,
        fontStyle: model.isItalic ? FontStyle.italic : FontStyle.normal,
        fontWeight: model.isBold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
