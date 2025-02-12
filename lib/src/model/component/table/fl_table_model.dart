/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

part of 'package:flutter_jvx/src/model/component/fl_component_model.dart';

class FlTableModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// This style hides the floating insert button.
  static const String NO_FLOATING_BUTTON_STYLE = "f_no_float_insert";

  /// This style removes the alternating table row colors.
  static const String NO_ALTERNATING_ROW_COLOR_STYLE = "f_no_alternating_row_color";

  /// This style uses a list widget instead a table widget.
  static const String TABLE_AS_LIST_STYLE = "f_as_list";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Map<String, dynamic> json = {};

  String dataProvider = "";

  List<String> columnNames = [];

  List<String> columnLabels = [];

  /// If the table should reduce every column to fit into the available space
  bool autoResize = true;

  /// If the table as a whole should be editable.
  bool editable = true;

  /// the show table header flag
  bool tableHeaderVisible = true;

  /// the show vertical lines flag.
  bool showVerticalLines = false;

  /// the show horizontal lines flag.
  bool showHorizontalLines = true;

  /// the show selection flag.
  bool showSelection = true;

  /// the show focus rect flag.
  bool showFocusRect = false;

  /// if the tables sorts on header tab
  bool sortOnHeaderEnabled = true;

  /// if the table headers are sticky
  bool stickyHeaders = true;

  /// Word wrap
  bool wordWrapEnabled = false;

  /// If the table allows deletions.
  bool deleteEnabled = true;

  /// If the table hides the floating insert button.
  bool get showFloatButton => !styles.contains(NO_FLOATING_BUTTON_STYLE);

  /// If the table removes the alternating table row colors.
  bool get disabledAlternatingRowColor => styles.contains(NO_ALTERNATING_ROW_COLOR_STYLE);

  /// If the table should be visualized as list
  bool get asList => styles.contains(TABLE_AS_LIST_STYLE);

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

    editable = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.editable,
      pDefault: defaultModel.editable,
      pCurrent: editable,
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

    deleteEnabled = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.deleteEnabled,
      pDefault: defaultModel.deleteEnabled,
      pCurrent: deleteEnabled,
    );
  }
}
