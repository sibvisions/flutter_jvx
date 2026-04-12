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

  /// This style shows the floating insert button.
  static const String STYLE_FLOATING_BUTTON = "f_float_insert";

  /// This style hides the floating insert button.
  static const String STYLE_NO_FLOATING_BUTTON = "f_no_float_insert";

  /// This style removes the alternating table row colors.
  static const String STYLE_NO_ALTERNATING_ROW_COLOR = "f_no_alternating_row_color";

  /// This style uses a list widget instead a table widget.
  static const String STYLE_TABLE_AS_LIST = "f_as_list";

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
  bool get hideFloatButton => styles.contains(STYLE_NO_FLOATING_BUTTON);

  /// If the table hides the floating insert button.
  bool get showFloatButton => styles.contains(STYLE_FLOATING_BUTTON);

  /// If the table removes the alternating table row colors.
  bool get disabledAlternatingRowColor => styles.contains(STYLE_NO_ALTERNATING_ROW_COLOR);

  /// If the table should be visualized as list
  bool get asList => styles.contains(STYLE_TABLE_AS_LIST);

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
  void applyFromJson(Map<String, dynamic> newJson) {
    super.applyFromJson(newJson);
    ParseUtil.applyJsonToJson(newJson, json);

    dataProvider = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.dataBook,
      defaultValue: defaultModel.dataProvider,
      currentValue: dataProvider,
    );

    columnNames = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.columnNames,
      defaultValue: defaultModel.columnNames,
      currentValue: columnNames,
      conversion: (value) => List<String>.from(value),
    );

    columnLabels = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.columnLabels,
      defaultValue: defaultModel.columnLabels,
      currentValue: columnLabels,
      conversion: (value) => List<String>.from(value),
    );

    autoResize = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.autoResize,
      defaultValue: defaultModel.autoResize,
      currentValue: autoResize,
    );

    editable = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.editable,
      defaultValue: defaultModel.editable,
      currentValue: editable,
    );

    showVerticalLines = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.showVerticalLines,
      defaultValue: defaultModel.showVerticalLines,
      currentValue: showVerticalLines,
    );

    showHorizontalLines = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.showHorizontalLines,
      defaultValue: defaultModel.showHorizontalLines,
      currentValue: showHorizontalLines,
    );

    showSelection = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.showSelection,
      defaultValue: defaultModel.showSelection,
      currentValue: showSelection,
    );

    tableHeaderVisible = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.tableHeaderVisible,
      defaultValue: defaultModel.tableHeaderVisible,
      currentValue: tableHeaderVisible,
    );

    showFocusRect = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.showFocusRect,
      defaultValue: defaultModel.showFocusRect,
      currentValue: showFocusRect,
    );

    sortOnHeaderEnabled = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.sortOnHeaderEnabled,
      defaultValue: defaultModel.sortOnHeaderEnabled,
      currentValue: sortOnHeaderEnabled,
    );

    wordWrapEnabled = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.wordWrapEnabled,
      defaultValue: defaultModel.wordWrapEnabled,
      currentValue: wordWrapEnabled,
    );

    deleteEnabled = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.deleteEnabled,
      defaultValue: defaultModel.deleteEnabled,
      currentValue: deleteEnabled,
    );
  }
}
