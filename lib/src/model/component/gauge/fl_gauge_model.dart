import 'dart:ui';

import '../../api/api_object_property.dart';
import '../fl_component_model.dart';

class FlGaugeModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  String title = "";
  String dataProvider = "";
  double maxValue = 1;
  double minValue = 0;
  double? maxErrorValue;
  double? minErrorValue;
  double? maxWarningValue;
  double? minWarningValue;
  int gaugeStyle = 1;
  double? value;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlGaugeModel() : super() {
    preferredSize = const Size(300, 300);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    var jsonTitle = pJson[ApiObjectProperty.xAxisTitle];
    if (jsonTitle != null) {
      title = jsonTitle;
    }

    var jsonMaxValue = pJson[ApiObjectProperty.maxValue];
    if (jsonMaxValue != null) {
      maxValue = jsonMaxValue;
    }

    var jsonMinValue = pJson[ApiObjectProperty.minValue];
    if (jsonMinValue != null) {
      minValue = jsonMinValue;
    }

    var jsonMaxErrorValue = pJson[ApiObjectProperty.maxErrorValue];
    if (jsonMaxErrorValue != null) {
      maxErrorValue = jsonMaxErrorValue;
    }

    var jsonMinErrorValue = pJson[ApiObjectProperty.minErrorValue];
    if (jsonMinErrorValue != null) {
      minErrorValue = jsonMinErrorValue;
    }

    var jsonMaxWarningValue = pJson[ApiObjectProperty.maxWarningValue];
    if (jsonMaxWarningValue != null) {
      maxWarningValue = jsonMaxWarningValue;
    }

    var jsonMinWarningValue = pJson[ApiObjectProperty.minWarningValue];
    if (jsonMinWarningValue != null) {
      minWarningValue = jsonMinWarningValue;
    }

    var jsonDataProvider = pJson[ApiObjectProperty.dataRow];
    if (jsonDataProvider != null) {
      dataProvider = jsonDataProvider;
    }

    var jsonGaugeStyle = pJson[ApiObjectProperty.gaugeStyle];
    if (jsonGaugeStyle != null) {
      gaugeStyle = jsonGaugeStyle;
    }
    var jsonValue = pJson[ApiObjectProperty.data];
    if (jsonValue != null) {
      value = jsonValue.toDouble();
    }
  }
}
