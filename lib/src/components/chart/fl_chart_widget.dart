import 'package:charts_flutter/flutter.dart';
import 'package:flutter/widgets.dart';

import '../../model/component/chart/fl_chart_model.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlChartWidget<T extends FlChartModel> extends FlStatelessWidget<T> {
  final List<Series<dynamic, num>> series;

  const FlChartWidget({
    super.key,
    required super.model,
    required this.series,
  });

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) {
      return Container();
    }

    return LineChart(
      series,
      animate: false,
      layoutConfig: LayoutConfig(
        topMarginSpec: MarginSpec.fromPercent(minPercent: 2, maxPercent: 100),
        bottomMarginSpec: MarginSpec.fromPercent(minPercent: 5, maxPercent: 100),
        leftMarginSpec: MarginSpec.fromPercent(minPercent: 5, maxPercent: 100),
        rightMarginSpec: MarginSpec.fromPercent(minPercent: 2, maxPercent: 100),
      ),
    );
  }
}
