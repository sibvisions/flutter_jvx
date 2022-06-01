import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';

class FlTableModel extends FlComponentModel {
  String dataBook = "";

  List<String> columnNames = [];

  List<String>? columnLabels = [];

  bool autoResize = true;

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

  bool wordWrapEnabled = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  FlTableModel() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void applyFromJson(dynamic pJson) {
    super.applyFromJson(pJson);

    var jsonDataBook = pJson[ApiObjectProperty.dataBook];
    if (jsonDataBook != null) {
      dataBook = jsonDataBook;
    }

    var jsonColumnNames = pJson[ApiObjectProperty.columnNames];
    if (jsonColumnNames != null) {
      columnNames = List<String>.from(jsonColumnNames);
    }

    var jsonColumnLabels = pJson[ApiObjectProperty.columnLabels];
    if (jsonColumnLabels != null) {
      columnLabels = List<String>.from(jsonColumnLabels);
    }

    var jsonAutoResize = pJson[ApiObjectProperty.autoResize];
    if (jsonAutoResize != null) {
      autoResize = jsonAutoResize;
    }

    var jsonShowVerticalLines = pJson[ApiObjectProperty.showVerticalLines];
    if (jsonShowVerticalLines != null) {
      showVerticalLines = jsonShowVerticalLines;
    }

    var jsonShowHorizontalLines = pJson[ApiObjectProperty.showHorizontalLines];
    if (jsonShowHorizontalLines != null) {
      showHorizontalLines = jsonShowHorizontalLines;
    }

    var jsonShowSelection = pJson[ApiObjectProperty.showSelection];
    if (jsonShowSelection != null) {
      showSelection = jsonShowSelection;
    }

    var jsonTableHeaderVisible = pJson[ApiObjectProperty.tableHeaderVisible];
    if (jsonTableHeaderVisible != null) {
      tableHeaderVisible = jsonTableHeaderVisible;
    }

    var jsonShowFocusRect = pJson[ApiObjectProperty.showFocusRect];
    if (jsonShowFocusRect != null) {
      showFocusRect = jsonShowFocusRect;
    }

    var jsonSortOnHeaderEnabled = pJson[ApiObjectProperty.sortOnHeaderEnabled];
    if (jsonSortOnHeaderEnabled != null) {
      sortOnHeaderEnabled = jsonSortOnHeaderEnabled;
    }

    var jsonWordWrapEnabled = pJson[ApiObjectProperty.wordWrapEnabled];
    if (jsonWordWrapEnabled != null) {
      wordWrapEnabled = jsonWordWrapEnabled;
    }
  }

  int getColumnCount() {
    return getHeaders().length;
  }

  List<String> getHeaders() {
    return columnLabels ?? columnNames;
  }
}
