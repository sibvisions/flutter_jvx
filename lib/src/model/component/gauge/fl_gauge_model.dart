import 'dart:ui';

import '../../api/api_object_property.dart';
import '../fl_component_model.dart';
import '../interface/i_data_model.dart';

class FlGaugeModel extends FlComponentModel implements IDataModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  String title = "";
  @override
  String dataProvider = "";
  double maxValue = 1;
  double minValue = 0;
  double? maxErrorValue;
  double? minErrorValue;
  double? maxWarningValue;
  double? minWarningValue;
  int gaugeStyle = 0;
  double value = 0;
  String? columnLabel = "";

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
  FlGaugeModel get defaultModel => FlGaugeModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    title = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.title,
      pDefault: title,
      pCurrent: title,
    );

    maxValue = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.maxValue,
      pDefault: maxValue,
      pCurrent: maxValue,
    );

    minValue = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.minValue,
      pDefault: minValue,
      pCurrent: minValue,
    );

    maxErrorValue = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.maxErrorValue,
      pDefault: maxErrorValue,
      pCurrent: maxErrorValue,
    );

    minErrorValue = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.minErrorValue,
      pDefault: minErrorValue,
      pCurrent: minErrorValue,
    );

    maxWarningValue = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.maxWarningValue,
      pDefault: maxWarningValue,
      pCurrent: maxWarningValue,
    );

    minWarningValue = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.minWarningValue,
      pDefault: minWarningValue,
      pCurrent: minWarningValue,
    );

    dataProvider = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.dataRow,
      pDefault: dataProvider,
      pCurrent: dataProvider,
    );

    gaugeStyle = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.gaugeStyle,
      pDefault: gaugeStyle,
      pCurrent: gaugeStyle,
    );

    value = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.data,
      pDefault: value,
      pCurrent: value,
      pConversion: (conv) => conv.toDouble(),
    );

    columnLabel = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.columnLabel,
      pDefault: columnLabel,
      pCurrent: columnLabel,
    );
  }
}
