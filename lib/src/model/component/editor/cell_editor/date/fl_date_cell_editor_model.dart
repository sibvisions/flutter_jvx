import '../../../../../service/api/shared/api_object_property.dart';
import '../cell_editor_model.dart';

class FlDateCellEditorModel extends ICellEditorModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  String dateFormat = "d. MMMM yyyy HH:mm";

  String? timeZoneCode;

  bool isDateEditor = true;

  bool isTimeEditor = true;

  bool isHourEditor = true;

  bool isMinuteEditor = true;

  bool isSecondEditor = false;

  bool isAmPmEditor = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlDateCellEditorModel get defaultModel => FlDateCellEditorModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    dateFormat = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.dateFormat,
      pDefault: defaultModel.dateFormat,
      pCurrent: dateFormat,
      pConversion: (value) => value.replaceAll("Y", "y"),
    );

    timeZoneCode = getPropertyValue(
      pJson: pJson,
      //TODO await final name
      pKey: "timeZone",
      // pKey: ApiObjectProperty.timeZoneCode,
      pDefault: defaultModel.timeZoneCode,
      pCurrent: timeZoneCode,
    );

    isDateEditor = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.isDateEditor,
      pDefault: defaultModel.isDateEditor,
      pCurrent: isDateEditor,
    );
    isTimeEditor = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.isTimeEditor,
      pDefault: defaultModel.isTimeEditor,
      pCurrent: isTimeEditor,
    );

    isHourEditor = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.isHourEditor,
      pDefault: defaultModel.isHourEditor,
      pCurrent: isHourEditor,
    );

    isMinuteEditor = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.isMinuteEditor,
      pDefault: defaultModel.isMinuteEditor,
      pCurrent: isMinuteEditor,
    );

    isSecondEditor = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.isSecondEditor,
      pDefault: defaultModel.isSecondEditor,
      pCurrent: isSecondEditor,
    );
    isAmPmEditor = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.isAmPmEditor,
      pDefault: defaultModel.isAmPmEditor,
      pCurrent: isAmPmEditor,
    );
  }
}
