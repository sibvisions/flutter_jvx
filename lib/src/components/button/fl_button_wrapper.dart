import 'fl_button_widget.dart';
import '../../model/component/button/fl_button_model.dart';
import 'package:flutter/material.dart';

class FlButtonWrapper extends StatefulWidget {
  const FlButtonWrapper({Key? key, required this.model}) : super(key: key);

  final FlButtonModel model;

  @override
  _FlButtonWrapperState createState() => _FlButtonWrapperState();
}

class _FlButtonWrapperState extends State<FlButtonWrapper> {
  @override
  Widget build(BuildContext context) {
    return FlButtonWidget(buttonModel: widget.model);
  }
}
