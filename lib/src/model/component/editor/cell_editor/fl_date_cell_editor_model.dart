import '../../../api/api_object_property.dart';
import 'cell_editor_model.dart';

class FlDateCellEditorModel extends ICellEditorModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  String dateFormat = "d. MMMM yyyy HH:mm";

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
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    var jsonDateFormat = pJson['dateFormat'];
    if (jsonDateFormat != null) {
      dateFormat = jsonDateFormat.replaceAll('Y', 'y');
    }

    var jsonIsDateEditor = pJson[ApiObjectProperty.isDateEditor];
    if (jsonIsDateEditor != null) {
      isDateEditor = jsonIsDateEditor;
    }

    var jsonIsTimeEditor = pJson[ApiObjectProperty.isTimeEditor];
    if (jsonIsTimeEditor != null) {
      isTimeEditor = jsonIsTimeEditor;
    }

    var jsonIsHourEditor = pJson[ApiObjectProperty.isHourEditor];
    if (jsonIsHourEditor != null) {
      isHourEditor = jsonIsHourEditor;
    }

    var jsonIsMinuteEditor = pJson[ApiObjectProperty.isMinuteEditor];
    if (jsonIsMinuteEditor != null) {
      isMinuteEditor = jsonIsMinuteEditor;
    }

    var jsonIsSecondEditor = pJson[ApiObjectProperty.isSecondEditor];
    if (jsonIsSecondEditor != null) {
      isSecondEditor = jsonIsSecondEditor;
    }

    var jsonIsAmPmEditor = pJson[ApiObjectProperty.isAmPmEditor];
    if (jsonIsAmPmEditor != null) {
      isAmPmEditor = jsonIsAmPmEditor;
    }
  }
}
