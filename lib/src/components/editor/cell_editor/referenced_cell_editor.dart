/*
 * Copyright 2023 SIB Visions GmbH
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

import 'dart:convert';

import '../../../model/component/editor/cell_editor/linked/fl_linked_cell_editor_model.dart';
import '../../../model/component/editor/cell_editor/linked/reference_definition.dart';
import '../../../model/data/data_book.dart';
import '../../../service/data/i_data_service.dart';
import '../../../service/ui/i_ui_service.dart';

class ReferencedCellEditor {
  FlLinkedCellEditorModel cellEditorModel;
  String columnName;
  String dataProvider;

  ReferencedCellEditor(this.cellEditorModel, this.columnName, this.dataProvider);

  /// Builds a lookup table for this editor.
  ///
  /// Keys are json encoded maps that are inserted for every row.
  ///
  /// Example lookup table:
  /// ```dart
  /// '''
  /// {
  ///   "{"RESTRICT":["1"],"VALUE":["1"]}": "A Value",
  ///   "{"RESTRICT":["2"],"VALUE":["1"]}": "B Value",
  ///   "{"RESTRICT":["3"],"VALUE":["1"]}": "C Value",
  ///   "{"VALUE":["1"]}": "C Value", // Fallback
  /// }
  /// ''';
  /// ```
  void buildDataToDisplayMap(DataBook dataBook) {
    // As this cellEditor is in its referencedDataBook, every field from here named "referenced" usually refers to this DataBook instance.
    ReferenceDefinition linkReference = cellEditorModel.linkReference;
    Map<String, String> dataToDisplayMap = linkReference.dataToDisplay;

    if (cellEditorModel.displayConcatMask?.isNotEmpty == true ||
        cellEditorModel.displayReferencedColumnName?.isNotEmpty == true ||
        cellEditorModel.searchColumnMapping != null ||
        cellEditorModel.additionalCondition != null) {
      // Needed for general use cell editors (e.g. enum), whose linkReference doesn't necessarily contain configured columnNames.
      if (linkReference.columnNames.isEmpty) {
        linkReference.columnNames.add(columnName);
      }

      if (dataBook.metaData != null) {
        // Index in reference.
        int linkRefColumnIndex = linkReference.columnNames.indexWhere((e) => e == columnName);
        // Name of matching reference column.
        String referencedColumnName = linkReference.referencedColumnNames[linkRefColumnIndex];
        // Index of reference column in the referenced (this) data book.
        int referencedColumnIndex = dataBook.metaData!.columnDefinitions.indexByName(referencedColumnName);

        if (referencedColumnIndex >= 0) {
          dataBook.records.values.forEach((dataRow) {
            String displayString = cellEditorModel.createDisplayString(
              dataBook.metaData!.columnViewTable,
              dataBook.metaData!.columnDefinitions,
              dataRow,
            );

            Map<String, dynamic> displayKeyMap = cellEditorModel.createDisplayMapKey(
              dataBook.metaData!.columnDefinitions,
              dataRow,
              linkReference,
              columnName,
            );
            var displayKey = jsonEncode(displayKeyMap);
            dataToDisplayMap[displayKey] = displayString;

            var fallbackDataKey = jsonEncode(
                cellEditorModel.createFallbackDisplayKey(referencedColumnName, dataRow[referencedColumnIndex]));
            dataToDisplayMap[fallbackDataKey] = displayString;
          });
        }

        IUiService().notifyDataToDisplayMapChanged(pDataProvider: dataProvider);
      }
    }
  }

  void dispose() {
    DataBook? dataBook = IDataService().getDataBook(cellEditorModel.linkReference.referencedDataBook);

    if (dataBook != null) {
      dataBook.referencedCellEditors.remove(this);
    }
  }
}
