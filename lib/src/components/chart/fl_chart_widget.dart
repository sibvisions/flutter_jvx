import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';

import '../../model/component/chart/fl_chart_model.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlChartWidget<T extends FlChartModel> extends FlStatelessWidget<T> {
  final List<Series<dynamic, num>> series;

  const FlChartWidget({
    Key? key,
    required T model,
    required this.series,
  }) : super(key: key, model: model);

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) {
      return Container();
    }

    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        height: constraints.maxHeight,
        width: constraints.maxWidth,
        child: LineChart(
          series,
          layoutConfig: LayoutConfig(
            topMarginSpec: MarginSpec.defaultSpec,
            bottomMarginSpec: MarginSpec.defaultSpec,
            leftMarginSpec: MarginSpec.defaultSpec,
            rightMarginSpec: MarginSpec.defaultSpec,
          ),
        ),
      ),
    );
  }
}

//Syncfusion Chart
// SfCartesianChart(
//       title: ChartTitle(text: model.title, textStyle: model.getTextStyle()),
//       legend: Legend(isVisible: true),
//       tooltipBehavior: TooltipBehavior(enable: true),
//       series: series,
//       primaryXAxis: CategoryAxis(
//         labelPlacement: LabelPlacement.onTicks,
//         title: AxisTitle(
//           text: model.xAxisTitle,
//           textStyle: model.getTextStyle(),
//         ),
//       ),
//       primaryYAxis: NumericAxis(
//         title: AxisTitle(
//           text: model.yAxisTitle,
//           textStyle: model.getTextStyle(),
//         ),
//       ),
//     )