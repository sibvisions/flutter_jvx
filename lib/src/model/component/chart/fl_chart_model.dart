import 'dart:ui';

import '../../api/api_object_property.dart';
import '../fl_component_model.dart';

class FlChartModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  String xAxisTitle = "";
  String yAxisTitle = "";
  String xColumnName = "";
  List<String> yColumnNames = [];
  List yColumnLabels = [];
  String xColumnLabel = "";
  String title = "";
  String dataProvider = "";
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlChartModel() : super() {
    preferredSize = const Size(300, 300);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    var jsonXAxisTitle = pJson[ApiObjectProperty.xAxisTitle];
    if (jsonXAxisTitle != null) {
      xAxisTitle = jsonXAxisTitle;
    }

    var jsonYAxisTitle = pJson[ApiObjectProperty.yAxisTitle];
    if (jsonYAxisTitle != null) {
      yAxisTitle = jsonYAxisTitle;
    }

    var jsonXColumnName = pJson[ApiObjectProperty.xColumnName];
    if (jsonXColumnName != null) {
      xColumnName = jsonXColumnName;
    }

    var jsonYColumnNames = pJson[ApiObjectProperty.yColumnNames];
    if (jsonYColumnNames != null) {
      yColumnNames = List<String>.from(jsonYColumnNames);
    }

    var jsonTitle = pJson[ApiObjectProperty.title];
    if (jsonTitle != null) {
      title = jsonTitle;
    }

    var jsonYColumnLabels = pJson[ApiObjectProperty.yColumnLabels];
    if (jsonYColumnNames != null) {
      yColumnLabels = jsonYColumnLabels;
    }

    var jsonXColumnLabel = pJson[ApiObjectProperty.xColumnLabel];
    if (jsonXColumnLabel != null) {
      xColumnLabel = jsonXColumnLabel;
    }

    var jsonDataBook = pJson[ApiObjectProperty.dataBook];
    if (jsonDataBook != null) {
      dataProvider = jsonDataBook;
    }
  }
}
