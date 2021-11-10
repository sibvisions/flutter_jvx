import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterclient/src/ui/screen/core/so_screen.dart';

import 'component_widget.dart';
import 'model/chart_component_model.dart';

class CoChartWidget extends ComponentWidget {
  final ChartComponentModel componentModel;

  CoChartWidget({required this.componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoChartWidgetState();
}

class CoChartWidgetState extends ComponentWidgetState<CoChartWidget> {
  bool animate = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.componentModel.data == null) {
      widget.componentModel.data = SoScreen.of(context)!
          .getComponentData(widget.componentModel.dataBook);
    }
  }

  Widget _getChart() {
    return LineChart(
      _createSeries(),
      animate: animate,
    );
  }

  List<Series<List, int>> _createSeries() {
    List<Series<List, int>> _series = <Series<List, int>>[];

    return _series;
  }

  // @override
  // Widget build(BuildContext context) {
  //   return _getChart();
  // }
}
