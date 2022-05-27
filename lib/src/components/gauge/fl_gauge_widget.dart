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
    switch (model.gaugeStyle) {
      case 0:
        return getGauge0();
      case 1:
        return getGauge1();
      case 2:
        return getGauge2();
      case 3:
        return getGauge3();
      default:
        return getGauge1();
    }
  }

  Widget getGauge0() {
    return SfRadialGauge(
      axes: [
        RadialAxis(
          maximum: model.maxValue,
          minimum: model.minValue,
          ranges: getRanges(),
          pointers: [
            NeedlePointer(value: model.value),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
                widget: Text(
                  model.columnLabel ?? model.value.toString(),
                  style: model.getTextStyle(),
                ),
                angle: 90,
                positionFactor: 0.5),
          ],
        ),
      ],
    );
  }

  Widget getGauge1() {
    return SfRadialGauge(
      axes: [
        RadialAxis(
          maximum: model.maxValue,
          minimum: model.minValue,
          ranges: getRanges(),
          startAngle: 200,
          endAngle: 340,
          pointers: [
            NeedlePointer(
              value: model.value,
              lengthUnit: GaugeSizeUnit.factor,
              needleLength: 1,
              needleColor: Colors.red,
              needleStartWidth: 2,
              needleEndWidth: 2,
              knobStyle: const KnobStyle(knobRadius: 0),
            ),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
                widget: Text(
                  model.columnLabel ?? model.value.toString(),
                  style: model.getTextStyle(),
                ),
                angle: 90,
                positionFactor: 0.1),
          ],
        ),
      ],
    );
  }

  Widget getGauge2() {
    return SfRadialGauge(
      axes: [
        RadialAxis(
          showLabels: false,
          showTicks: false,
          startAngle: 270,
          endAngle: 270,
          maximum: model.maxValue,
          minimum: model.minValue,
          axisLineStyle: const AxisLineStyle(
            thickness: 0.25,
            thicknessUnit: GaugeSizeUnit.factor,
          ),
          pointers: [
            RangePointer(
              value: model.value,
              sizeUnit: GaugeSizeUnit.factor,
              width: 0.25,
              color: getRangeColor(),
            )
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              axisValue: 50,
              positionFactor: 0.1,
              widget: Text(
                model.columnLabel ?? model.value.toString(),
                style: model.getTextStyle(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget getGauge3() {
    return SfRadialGauge(
      axes: [
        RadialAxis(
          showLabels: false,
          showTicks: false,
          startAngle: 180,
          endAngle: 360,
          maximum: model.maxValue,
          minimum: model.minValue,
          axisLineStyle: const AxisLineStyle(
            thickness: 0.25,
            thicknessUnit: GaugeSizeUnit.factor,
          ),
          pointers: [
            RangePointer(
              value: model.value,
              sizeUnit: GaugeSizeUnit.factor,
              width: 0.25,
              color: getRangeColor(),
            )
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              axisValue: 50,
              positionFactor: 0.1,
              widget: Text(
                model.columnLabel ?? model.value.toString(),
                style: model.getTextStyle(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color getRangeColor() {
    Color colorToShow = Colors.green;

    if (model.minWarningValue != null) {
      if (model.minValue < model.value && model.value < model.minWarningValue!) {
        colorToShow = Colors.yellow;
      }
    }
    if (model.maxWarningValue != null) {
      if (model.maxWarningValue! < model.value && model.value < model.maxValue) {
        colorToShow = Colors.yellow;
      }
    }
    if (model.minErrorValue != null) {
      if (model.minValue < model.value && model.value < model.minErrorValue!) {
        colorToShow = Colors.red;
      }
    }
    if (model.maxErrorValue != null) {
      if (model.maxErrorValue! < model.value && model.value < model.maxValue) {
        colorToShow = Colors.red;
      }
    }
    return colorToShow;
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
