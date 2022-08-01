import '../../../../util/parse_util.dart';
import '../../../service/api/shared/api_object_property.dart';
import '../fl_component_model.dart';
import '../interface/i_data_model.dart';

class FlTableModel extends FlComponentModel implements IDataModel {
  Map<String, dynamic> json = {};

  @override
  String dataProvider = "";

  List<String> columnNames = [];

  List<String>? columnLabels;

  /// If the table should reduce every column to fit into the available space
  bool autoResize = false;

  /// If the table as a whole should be editable.
  bool editable = true;

  /// the show table header flag
  bool tableHeaderVisible = true;

  /// the show vertical lines flag.
  bool showVerticalLines = true;

  /// the show horizontal lines flag.
  bool showHorizontalLines = true;

  /// the show selection flag.
  bool showSelection = true;

  /// the show focus rect flag.
  bool showFocusRect = true;

  /// if the tables sorts on header tab
  bool sortOnHeaderEnabled = true;

  /// if the table headers are sticky
  bool stickyHeaders = true;

  /// Word wrap
  bool wordWrapEnabled = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  FlTableModel();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlTableModel get defaultModel => FlTableModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);
    ParseUtil.applyJsonToJson(pJson, json);

    dataProvider = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.dataBook,
      pDefault: defaultModel.dataProvider,
      pCurrent: dataProvider,
    );

    columnNames = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.columnNames,
      pDefault: defaultModel.columnNames,
      pCurrent: columnNames,
      pConversion: (value) => List<String>.from(value),
    );

    columnLabels = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.columnLabels,
      pDefault: defaultModel.columnLabels,
      pCurrent: columnLabels,
      pConversion: (value) => List<String>.from(value),
    );

    autoResize = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.autoResize,
      pDefault: defaultModel.autoResize,
      pCurrent: autoResize,
    );

    showVerticalLines = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.showVerticalLines,
      pDefault: defaultModel.showVerticalLines,
      pCurrent: showVerticalLines,
    );

    showHorizontalLines = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.showHorizontalLines,
      pDefault: defaultModel.showHorizontalLines,
      pCurrent: showHorizontalLines,
    );

    showSelection = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.showSelection,
      pDefault: defaultModel.showSelection,
      pCurrent: showSelection,
    );

    tableHeaderVisible = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.tableHeaderVisible,
      pDefault: defaultModel.tableHeaderVisible,
      pCurrent: tableHeaderVisible,
    );

    showFocusRect = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.showFocusRect,
      pDefault: defaultModel.showFocusRect,
      pCurrent: showFocusRect,
    );

    sortOnHeaderEnabled = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.sortOnHeaderEnabled,
      pDefault: defaultModel.sortOnHeaderEnabled,
      pCurrent: sortOnHeaderEnabled,
    );

    wordWrapEnabled = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.wordWrapEnabled,
      pDefault: defaultModel.wordWrapEnabled,
      pCurrent: wordWrapEnabled,
    );
  }

  int getColumnCount() {
    return getHeaders().length;
  }

  List<String> getHeaders() {
    return columnLabels ?? columnNames;
  }
}
