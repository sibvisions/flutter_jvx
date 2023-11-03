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

import 'package:collection/collection.dart';
import 'package:flutter/animation.dart';

import '../../../../../service/api/shared/api_object_property.dart';
import '../../../../../service/config/i_config_service.dart';
import '../../../../data/column_definition.dart';
import '../../../../data/data_book.dart';
import '../../../fl_component_model.dart';
import '../cell_editor_model.dart';
import 'column_mapping.dart';
import 'column_view.dart';
import 'condition/base_condition.dart';
import 'condition/compare_condition.dart';
import 'condition/operator_condition.dart';
import 'reference_definition.dart';

class FlLinkedCellEditorModel extends ICellEditorModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ReferenceDefinition linkReference = ReferenceDefinition(referencedDataBook: "");

  ColumnView? columnView;

  String? displayReferencedColumnName;

  String? displayConcatMask;

  ColumnMapping? searchColumnMapping;

  BaseCondition? additionalCondition;

  bool searchTextAnywhere = true;

  bool searchInAllTableColumns = false;

  bool sortByColumnName = false;

  bool tableHeaderVisible = true;

  bool validationEnabled = true;

  bool doNotClearColumnNames = true;

  bool tableReadonly = true;

  List<String>? additionalClearColumnNames;

  List<String>? clearColumnNames;

  Size? popupSize;

  /// If the table removes the alternating table row colors.
  bool get disabledAlternatingRowColor => styles.contains(FlTableModel.NO_ALTERNATING_ROW_COLOR_STYLE);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlLinkedCellEditorModel get defaultModel => FlLinkedCellEditorModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    linkReference = getPropertyValue(
        pJson: pJson,
        pKey: ApiObjectProperty.linkReference,
        pDefault: defaultModel.linkReference,
        pCurrent: linkReference,
        pConversion: (value) => ReferenceDefinition.fromJson(value));

    columnView = getPropertyValue(
        pJson: pJson,
        pKey: ApiObjectProperty.columnView,
        pDefault: defaultModel.columnView,
        pCurrent: columnView,
        pConversion: (value) => ColumnView.fromJson(value));

    displayReferencedColumnName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.displayReferencedColumnName,
      pDefault: defaultModel.displayReferencedColumnName,
      pCurrent: displayReferencedColumnName,
    );

    displayConcatMask = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.displayConcatMask,
      pDefault: defaultModel.displayConcatMask,
      pCurrent: displayConcatMask,
    );

    searchColumnMapping = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.searchColumnMapping,
      pDefault: defaultModel.searchColumnMapping,
      pConversion: (value) => ColumnMapping.fromJson(value),
      pCurrent: searchColumnMapping,
    );

    additionalCondition = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.additionalCondition,
      pDefault: defaultModel.additionalCondition,
      pCurrent: additionalCondition,
      pConversion: (value) => BaseCondition.parseCondition(value),
    );

    searchTextAnywhere = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.searchTextAnywhere,
      pDefault: defaultModel.searchTextAnywhere,
      pCurrent: searchTextAnywhere,
    );

    searchInAllTableColumns = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.searchInAllTableColumns,
      pDefault: defaultModel.searchInAllTableColumns,
      pCurrent: searchInAllTableColumns,
    );

    sortByColumnName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.sortByColumnName,
      pDefault: defaultModel.sortByColumnName,
      pCurrent: sortByColumnName,
    );

    tableHeaderVisible = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.tableHeaderVisible,
      pDefault: defaultModel.tableHeaderVisible,
      pCurrent: tableHeaderVisible,
    );

    validationEnabled = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.validationEnabled,
      pDefault: defaultModel.validationEnabled,
      pCurrent: validationEnabled,
    );

    tableReadonly = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.tableReadonly,
      pDefault: defaultModel.tableReadonly,
      pCurrent: tableReadonly,
    );

    popupSize = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.popupSize,
      pDefault: defaultModel.popupSize,
      pCurrent: popupSize,
      pConversion: (pJson) => _parsePopupSize(pJson),
    );

    additionalClearColumnNames = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.additionalClearColumns,
      pDefault: defaultModel.additionalClearColumnNames,
      pCurrent: additionalClearColumnNames,
      pConversion: (value) => value.cast<String>(),
    );

    clearColumnNames = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.clearColumns,
      pDefault: defaultModel.clearColumnNames,
      pCurrent: clearColumnNames,
      pConversion: (value) => value.cast<String>(),
    );
  }

  Size? _parsePopupSize(Map<String, dynamic> pJson) {
    if (!pJson.containsKey("width") || !pJson.containsKey("height")) {
      return null;
    }

    num width = pJson['width'];
    num height = pJson['height'];
    return Size(width.toDouble(), height.toDouble()) * IConfigService().getScaling();
  }

  /// Creates the display value for the linked cell editor
  /// depending on the concatMask and displayReferencedColumnName.
  String createDisplayString(
    List<String> columnViewTable,
    List<ColumnDefinition> columnDefinitions,
    List<dynamic> dataRow,
  ) {
    String displayString = "";

    if (displayConcatMask?.isNotEmpty == true) {
      List<String> columnViewNames = columnView?.columnNames ?? columnViewTable;

      if (displayConcatMask!.contains("*")) {
        int i = 0;

        displayString = displayConcatMask!;
        while (displayString.contains("*")) {
          int valueIndex =
              i < columnViewNames.length ? columnDefinitions.indexWhere((e) => e.name == columnViewNames[i]) : -1;

          dynamic value = valueIndex >= 0 ? dataRow[valueIndex] : "";

          displayString = displayString.replaceFirst('*', value.toString());
          i++;
        }
      } else {
        List<String> values = [];
        columnViewNames.forEach((columnName) {
          int valueIndex = columnDefinitions.indexWhere((e) => e.name == columnName);

          values.add(valueIndex >= 0 ? dataRow[valueIndex] : "");
        });
        displayString = values.join(displayConcatMask!);
      }
    } else if (displayReferencedColumnName?.isNotEmpty == true) {
      displayString = dataRow[columnDefinitions.indexWhere((e) => e.name == displayReferencedColumnName)].toString();
    }

    return displayString;
  }

  /// Creates the key for a link reference.
  ///
  /// Produces keys like:
  /// ```dart
  /// '''
  /// {
  ///   "RESTRICT": ["3"],
  ///   "VALUE": ["1"],
  /// }
  /// ''';
  /// ```
  Map<String, dynamic> createDisplayMapKey(
    List<ColumnDefinition> columnDefinitions,
    List<dynamic> dataRow,
    ReferenceDefinition linkReference,
    String columnName, {
    String? dataProvider,
  }) {
    Map<String, dynamic> keyObject = {};

    if (searchColumnMapping != null) {
      addSearchColumnMappings(
        columnDefinitions,
        dataRow,
        keyObject,
        searchColumnMapping!,
      );
    }

    if (additionalCondition != null) {
      addAdditionalConditions(
        columnDefinitions,
        dataRow,
        keyObject,
        additionalCondition!,
        dataProvider,
      );
    }

    var linkRefColumnIndex = linkReference.columnNames.indexWhere((e) => e == columnName);
    var columnIndex = DataBook.getColumnIndex(columnDefinitions, columnName);
    var refColumnIndex =
        DataBook.getColumnIndex(columnDefinitions, linkReference.referencedColumnNames[linkRefColumnIndex]);
    keyObject[linkReference.referencedColumnNames[linkRefColumnIndex]] = [
      dataRow[columnIndex == -1 ? refColumnIndex : columnIndex].toString(),
    ];

    return keyObject;
  }

  /// Adds key columns to [keyObject].
  void addSearchColumnMappings(
    List<ColumnDefinition> columnDefinitions,
    List<dynamic> dataRow,
    Map<String, dynamic> keyObject,
    ColumnMapping searchColumnMapping,
  ) {
    searchColumnMapping.columnNames.forEachIndexed((i, columnName) {
      var columnIndex = DataBook.getColumnIndex(columnDefinitions, columnName);
      var refColumnIndex = DataBook.getColumnIndex(columnDefinitions, searchColumnMapping.referencedColumnNames[i]);
      keyObject[searchColumnMapping.referencedColumnNames[i]] = [
        dataRow[columnIndex == -1 ? refColumnIndex : columnIndex].toString(),
      ];
    });
  }

  /// Adds compatible conditions recursively to [keyObject].
  void addAdditionalConditions(
    List<ColumnDefinition> columnDefinitions,
    List<dynamic> dataRow,
    Map<String, dynamic> keyObject,
    BaseCondition additionalCondition,
    String? dataProvider,
  ) {
    if (additionalCondition is CompareCondition) {
      // Only use Equals conditions (or when there is no type: backwards compatibility)
      if (additionalCondition.type.toLowerCase() == "equals") {
        // If dataProvider is build map then the map is initially built, then the dataRow already contains the referencedColumnNames
        if (dataProvider == null) {
          keyObject[additionalCondition.columnName] = [
            dataRow[DataBook.getColumnIndex(columnDefinitions, additionalCondition.columnName)].toString(),
          ];
        } else {
          // Check if the dataRow of the additionalCondition is the given dataProvider, if yes, use the value of the column of the dataRow, if not, use the value of the additionalCondition
          keyObject[additionalCondition.columnName] = [
            additionalCondition.dataRow == dataProvider
                ? dataRow[DataBook.getColumnIndex(columnDefinitions, additionalCondition.dataRowColumnName)].toString()
                : additionalCondition.value.toString(),
          ];
        }
      }
    } else if (additionalCondition is OperatorCondition) {
      if (additionalCondition.conditions != null) {
        additionalCondition.conditions!.forEach(
          (addCon) => addAdditionalConditions(
            columnDefinitions,
            dataRow,
            keyObject,
            addCon,
            dataProvider,
          ),
        );
      } else if (additionalCondition.condition != null) {
        addAdditionalConditions(
          columnDefinitions,
          dataRow,
          keyObject,
          additionalCondition.condition!,
          dataProvider,
        );
      }
    }
  }

  /// Creates the fallback key for the display map.
  ///
  /// This is for backwards compatibility in case the conditions wouldn't match
  ///
  /// This is just the default "columnName: columnValue" pair.
  Map<String, dynamic> createFallbackDisplayKey(String referencedColumnName, dynamic referencedColumnValue) {
    return {
      referencedColumnName: [referencedColumnValue.toString()],
    };
  }
}
