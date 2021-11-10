import 'package:flutter/material.dart';
import 'package:flutterclient/src/ui/component/model/gauge_component_model.dart';

import 'component_widget.dart';

class CoGaugeWidget extends ComponentWidget {
  final GaugeComponentModel componentModel;

  CoGaugeWidget({required this.componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoGaugeWidgetState();
}

class CoGaugeWidgetState extends ComponentWidgetState<CoGaugeWidget> {
  @override
  void initState() {
    super.initState();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return SizedBox(
  //       width: 50,
  //       height: 50,
  //       child: FlutterGauge(
  //           handSize: 30,
  //           width: 200,
  //           index: 65.0,
  //           fontFamily: "Iran",
  //           end: 100,
  //           number: Number.endAndCenterAndStart,
  //           secondsMarker: SecondsMarker.secondsAndMinute,
  //           counterStyle: TextStyle(
  //             color: Colors.black,
  //             fontSize: 25,
  //           )));
  // }
}
