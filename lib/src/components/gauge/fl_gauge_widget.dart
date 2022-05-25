import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../model/component/gauge/fl_gauge_model.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlGaugeWidget<T extends FlGaugeModel> extends FlStatelessWidget<T> {
  const FlGaugeWidget({
    Key? key,
    required T model,
  }) : super(key: key, model: model);

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      axes: [
        RadialAxis(
          maximum: model.maxValue,
          minimum: model.minValue,
          ranges: getRanges(),
          pointers: [
            NeedlePointer(value: model.value ?? 0),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
                widget: Text(
                  model.value.toString(),
                  style: model.getTextStyle(),
                ),
                angle: 90,
                positionFactor: 0.5),
          ],
        ),
      ],
    );
  }

  List<GaugeRange> getRanges() {
    List<GaugeRange> ranges = [];

    ranges.add(GaugeRange(
      startValue: model.minValue,
      endValue: model.maxValue,
      color: Colors.green,
    ));
    if (model.minWarningValue != null) {
      ranges.add(GaugeRange(
        startValue: model.minValue,
        endValue: model.minWarningValue!,
        color: Colors.yellow,
      ));
    }
    if (model.maxWarningValue != null) {
      ranges.add(GaugeRange(
        startValue: model.maxWarningValue!,
        endValue: model.maxValue,
        color: Colors.yellow,
      ));
    }

    if (model.minErrorValue != null) {
      ranges.add(GaugeRange(
        startValue: model.minValue,
        endValue: model.minErrorValue!,
        color: Colors.red,
      ));
    }
    if (model.maxErrorValue != null) {
      ranges.add(GaugeRange(
        startValue: model.maxErrorValue!,
        endValue: model.maxValue,
        color: Colors.red,
      ));
    }
    return ranges;
  }
}
