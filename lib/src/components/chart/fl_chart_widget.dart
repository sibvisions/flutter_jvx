import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../model/component/chart/fl_chart_model.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlChartWidget<T extends FlChartModel> extends FlStatelessWidget<T> {
  final List<ChartSeries> series;

  const FlChartWidget({
    Key? key,
    required T model,
    required this.series,
  }) : super(key: key, model: model);

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: model.title, textStyle: model.getTextStyle()),
      legend: Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: series,
      primaryXAxis: CategoryAxis(
        labelPlacement: LabelPlacement.onTicks,
        title: AxisTitle(
          text: model.xAxisTitle,
          textStyle: model.getTextStyle(),
        ),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(
          text: model.yAxisTitle,
          textStyle: model.getTextStyle(),
        ),
      ),
    );
  }
}
