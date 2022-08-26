import 'dart:ui';

import '../../../service/api/shared/api_object_property.dart';
import '../fl_component_model.dart';
import '../interface/i_data_model.dart';

class FlChartModel extends FlComponentModel implements IDataModel {
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

  @override
  String dataProvider = "";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlChartModel() : super() {
    preferredSize = const Size(100, 100);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlChartModel get defaultModel => FlChartModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    xAxisTitle = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.xAxisTitle,
      pDefault: defaultModel.xAxisTitle,
      pCurrent: xAxisTitle,
    );

    yAxisTitle = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.yAxisTitle,
      pDefault: defaultModel.yAxisTitle,
      pCurrent: yAxisTitle,
    );
    xColumnName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.xColumnName,
      pDefault: defaultModel.xColumnName,
      pCurrent: xColumnName,
    );

    yColumnNames = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.yColumnNames,
      pDefault: defaultModel.yColumnNames,
      pCurrent: yColumnNames,
      pConversion: (value) => List<String>.from(value),
    );

    title = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.title,
      pDefault: defaultModel.title,
      pCurrent: title,
    );

    yColumnLabels = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.yColumnLabels,
      pDefault: defaultModel.yColumnLabels,
      pCurrent: yColumnLabels,
      pConversion: (value) => List<String>.from(value),
    );

    xColumnLabel = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.xColumnLabel,
      pDefault: defaultModel.xColumnLabel,
      pCurrent: xColumnLabel,
    );
    dataProvider = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.dataBook,
      pDefault: defaultModel.dataProvider,
      pCurrent: dataProvider,
    );
  }
}
