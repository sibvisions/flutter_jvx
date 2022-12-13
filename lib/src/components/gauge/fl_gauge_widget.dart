/* Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:flutter/material.dart';
import 'package:gauges/gauges.dart';

import '../../model/component/gauge/fl_gauge_model.dart';
import '../../util/jvx_colors.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlGaugeWidget<T extends FlGaugeModel> extends FlStatelessWidget<T> {
  const FlGaugeWidget({super.key, required super.model});

  @override
  Widget build(BuildContext context) {
    switch (model.gaugeStyle) {
      case 0:
        return createSpeedometer(context);
      case 1:
        return createMeter(context);
      case 2:
        return createRing(context);
      case 3:
        return createFlat(context);
      default:
        return createSpeedometer(context);
    }
  }

  Widget createMeter(context) {
    return Center(
      child: RadialGauge(
        axes: [
          RadialGaugeAxis(
            maxValue: model.maxValue,
            minValue: model.minValue,
            minAngle: -65,
            maxAngle: 65,
            segments: getSegmentsMeter(),
            pointers: [
              RadialNeedlePointer(
                value: model.value,
                thicknessStart: 20,
                thicknessEnd: 0,
                length: 0.6,
                knobRadiusAbsolute: 10,
              ),
            ],
            ticks: [
              RadialTicks(
                interval: (model.maxValue - model.minValue) / 5,
                alignment: RadialTickAxisAlignment.below,
                color: JVxColors.LIGHTER_BLACK,
                length: 0.2,
                children: [
                  RadialTicks(
                    ticksInBetween: 3,
                    length: 0.1,
                    color: Colors.black54,
                    alignment: RadialTickAxisAlignment.below,
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget createSpeedometer(context) {
    return Center(
      child: RadialGauge(
        axes: [
          RadialGaugeAxis(
            maxValue: model.maxValue,
            minValue: model.minValue,
            minAngle: 200,
            maxAngle: 520,
            segments: getSegmentsSpeedometer(),
            pointers: [
              RadialNeedlePointer(
                value: model.value,
                thicknessStart: 20,
                thicknessEnd: 0,
                length: 0.6,
                knobRadiusAbsolute: 10,
              ),
            ],
            ticks: [
              RadialTicks(
                interval: (model.maxValue - model.minValue) / 10,
                alignment: RadialTickAxisAlignment.inside,
                color: JVxColors.LIGHTER_BLACK,
                length: 0.3,
                children: [
                  RadialTicks(ticksInBetween: 3, length: 0.25, color: Colors.black54),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget createRing(context) {
    return Center(
      child: RadialGauge(
        axes: [
          RadialGaugeAxis(
            maxValue: model.maxValue,
            minValue: model.minValue,
            minAngle: -90,
            maxAngle: 270,
            segments: getSegmentsRing(),
          ),
        ],
      ),
    );
  }

  Widget createFlat(context) {
    return Center(
      child: RadialGauge(
        axes: [
          RadialGaugeAxis(
            maxValue: model.maxValue,
            minValue: model.minValue,
            minAngle: -90,
            maxAngle: 90,
            segments: getSegmentsFlat(),
          ),
        ],
      ),
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

  List<RadialGaugeSegment> getSegmentsMeter() {
    double gradePerVal = 130 / (model.maxValue - model.minValue);
    List<RadialGaugeSegment> segments = [];

    segments.add(RadialGaugeSegment(
      width: 0.1,
      minValue: model.minValue,
      maxValue: model.maxValue,
      minAngle: -65,
      maxAngle: 65,
      color: Colors.green,
    ));
    if (model.minWarningValue != null) {
      segments.add(RadialGaugeSegment(
        width: 0.1,
        minValue: model.minValue,
        maxValue: model.minWarningValue!,
        minAngle: -65,
        maxAngle: -65 + gradePerVal * (model.minWarningValue! - model.minValue),
        color: Colors.yellow,
      ));
    }
    if (model.maxWarningValue != null) {
      segments.add(RadialGaugeSegment(
        width: 0.1,
        minValue: model.maxWarningValue!,
        maxValue: model.maxValue,
        minAngle: 65 - gradePerVal * (model.maxValue - model.maxWarningValue!),
        maxAngle: 65,
        color: Colors.yellow,
      ));
    }

    if (model.minErrorValue != null) {
      segments.add(RadialGaugeSegment(
        width: 0.1,
        minValue: model.minValue,
        maxValue: model.minErrorValue!,
        minAngle: -65,
        maxAngle: -65 + gradePerVal * (model.minErrorValue! - model.minValue),
        color: Colors.red,
      ));
    }
    if (model.maxErrorValue != null) {
      segments.add(RadialGaugeSegment(
        width: 0.1,
        minValue: model.maxErrorValue!,
        maxValue: model.maxValue,
        minAngle: 65 - gradePerVal * (model.maxValue - model.maxErrorValue!),
        maxAngle: 65,
        color: Colors.red,
      ));
    }
    return segments;
  }

  List<RadialGaugeSegment> getSegmentsSpeedometer() {
    double gradePerVal = 320 / (model.maxValue - model.minValue);
    List<RadialGaugeSegment> segments = [];

    segments.add(RadialGaugeSegment(
      minValue: model.minValue,
      maxValue: model.maxValue,
      minAngle: 200,
      maxAngle: 520,
      color: Colors.green,
    ));
    if (model.minWarningValue != null) {
      segments.add(RadialGaugeSegment(
        minValue: model.minValue,
        maxValue: model.minWarningValue!,
        minAngle: 200,
        maxAngle: 200 + gradePerVal * (model.minWarningValue! - model.minValue),
        color: Colors.yellow,
      ));
    }
    if (model.maxWarningValue != null) {
      segments.add(RadialGaugeSegment(
        minValue: model.maxWarningValue!,
        maxValue: model.maxValue,
        minAngle: 520 - gradePerVal * (model.maxValue - model.maxWarningValue!),
        maxAngle: 520,
        color: Colors.yellow,
      ));
    }

    if (model.minErrorValue != null) {
      segments.add(RadialGaugeSegment(
        minValue: model.minValue,
        maxValue: model.minErrorValue!,
        minAngle: 200,
        maxAngle: 200 + gradePerVal * (model.minErrorValue! - model.minValue),
        color: Colors.red,
      ));
    }
    if (model.maxErrorValue != null) {
      segments.add(RadialGaugeSegment(
        minValue: model.maxErrorValue!,
        maxValue: model.maxValue,
        minAngle: 520 - gradePerVal * (model.maxValue - model.maxErrorValue!),
        maxAngle: 520,
        color: Colors.red,
      ));
    }
    return segments;
  }

  List<RadialGaugeSegment> getSegmentsRing() {
    double gradePerVal = 360 / (model.maxValue - model.minValue);
    List<RadialGaugeSegment> segments = [];

    segments.add(RadialGaugeSegment(
      minValue: model.minValue,
      maxValue: model.maxValue,
      minAngle: -90,
      maxAngle: 270,
      color: Colors.grey,
    ));

    if (model.value != 0) {
      segments.add(RadialGaugeSegment(
        minValue: model.minValue,
        maxValue: model.minWarningValue!,
        minAngle: -90,
        maxAngle: -90 + gradePerVal * model.value,
        color: getRangeColor(),
      ));
    }

    return segments;
  }

  List<RadialGaugeSegment> getSegmentsFlat() {
    double gradePerVal = 180 / (model.maxValue - model.minValue);
    List<RadialGaugeSegment> segments = [];

    segments.add(RadialGaugeSegment(
      minValue: model.minValue,
      maxValue: model.maxValue,
      minAngle: -90,
      maxAngle: 90,
      color: Colors.grey,
    ));

    if (model.value != 0) {
      segments.add(RadialGaugeSegment(
        minValue: model.minValue,
        maxValue: model.minWarningValue!,
        minAngle: -90,
        maxAngle: -90 + gradePerVal * model.value,
        color: getRangeColor(),
      ));
    }

    return segments;
  }
}

// Syncfusion Widget
// Widget createSpeedometer() {
//   return SfRadialGauge(
//     axes: [
//       RadialAxis(
//         maximum: model.maxValue,
//         minimum: model.minValue,
//         ranges: getRanges(),
//         pointers: [
//           NeedlePointer(value: model.value),
//         ],
//         annotations: <GaugeAnnotation>[
//           GaugeAnnotation(
//               widget: Text(
//                 model.columnLabel ?? "",
//                 style: model.getTextStyle(),
//               ),
//               angle: 90,
//               positionFactor: 0.5),
//         ],
//       ),
//     ],
//   );
// }

// Widget createMeter() {
//   return SfRadialGauge(
//     axes: [
//       RadialAxis(
//         maximum: model.maxValue,
//         minimum: model.minValue,
//         ranges: getRanges(),
//         startAngle: 200,
//         endAngle: 340,
//         pointers: [
//           NeedlePointer(
//             value: model.value,
//             lengthUnit: GaugeSizeUnit.factor,
//             needleLength: 1,
//             needleColor: Colors.red,
//             needleStartWidth: 2,
//             needleEndWidth: 2,
//             knobStyle: const KnobStyle(knobRadius: 0),
//           ),
//         ],
//         annotations: <GaugeAnnotation>[
//           GaugeAnnotation(
//               widget: Text(
//                 model.columnLabel ?? "",
//                 style: model.getTextStyle(),
//               ),
//               angle: 90,
//               positionFactor: 0.1),
//         ],
//       ),
//     ],
//   );
// }

// Widget createRing() {
//   return SfRadialGauge(
//     axes: [
//       RadialAxis(
//         showLabels: false,
//         showTicks: false,
//         startAngle: 270,
//         endAngle: 270,
//         maximum: model.maxValue,
//         minimum: model.minValue,
//         axisLineStyle: const AxisLineStyle(
//           thickness: 0.25,
//           thicknessUnit: GaugeSizeUnit.factor,
//         ),
//         pointers: [
//           RangePointer(
//             value: model.value,
//             sizeUnit: GaugeSizeUnit.factor,
//             width: 0.25,
//             color: getRangeColor(),
//           )
//         ],
//         annotations: <GaugeAnnotation>[
//           GaugeAnnotation(
//             axisValue: 50,
//             positionFactor: 0.1,
//             widget: Text(
//               model.columnLabel ?? "",
//               style: model.getTextStyle(),
//             ),
//           ),
//         ],
//       ),
//     ],
//   );
// }

// Widget createFlat() {
//   return SfRadialGauge(
//     axes: [
//       RadialAxis(
//         showLabels: false,
//         showTicks: false,
//         startAngle: 180,
//         endAngle: 360,
//         maximum: model.maxValue,
//         minimum: model.minValue,
//         axisLineStyle: const AxisLineStyle(
//           thickness: 0.25,
//           thicknessUnit: GaugeSizeUnit.factor,
//         ),
//         pointers: [
//           RangePointer(
//             value: model.value,
//             sizeUnit: GaugeSizeUnit.factor,
//             width: 0.25,
//             color: getRangeColor(),
//           )
//         ],
//         annotations: <GaugeAnnotation>[
//           GaugeAnnotation(
//             axisValue: 50,
//             positionFactor: 0.1,
//             widget: Text(
//               model.columnLabel ?? "",
//               style: model.getTextStyle(),
//             ),
//           ),
//         ],
//       ),
//     ],
//   );
// }

// List<GaugeRange> getRanges() {
//     List<GaugeRange> ranges = [];

//     ranges.add(GaugeRange(
//       startValue: model.minValue,
//       endValue: model.maxValue,
//       color: Colors.green,
//     ));
//     if (model.minWarningValue != null) {
//       ranges.add(GaugeRange(
//         startValue: model.minValue,
//         endValue: model.minWarningValue!,
//         color: Colors.yellow,
//       ));
//     }
//     if (model.maxWarningValue != null) {
//       ranges.add(GaugeRange(
//         startValue: model.maxWarningValue!,
//         endValue: model.maxValue,
//         color: Colors.yellow,
//       ));
//     }

//     if (model.minErrorValue != null) {
//       ranges.add(GaugeRange(
//         startValue: model.minValue,
//         endValue: model.minErrorValue!,
//         color: Colors.red,
//       ));
//     }
//     if (model.maxErrorValue != null) {
//       ranges.add(GaugeRange(
//         startValue: model.maxErrorValue!,
//         endValue: model.maxValue,
//         color: Colors.red,
//       ));
//     }
//     return ranges;
//   }
