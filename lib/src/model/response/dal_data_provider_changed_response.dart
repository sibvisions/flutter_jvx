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

import '../../flutter_ui.dart';
import '../../service/api/shared/api_object_property.dart';
import '../../util/sort_list.dart';
import '../data/sort_definition.dart';
import 'api_response.dart';
import 'record_format.dart';

class DalDataProviderChangedResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Data provider that changed
  final String dataProvider;

  /// -1 | x
  /// -1 - delete all local data and re-fetch
  /// x - re-fetch this specific row
  final int? reload;

  /// New selected row
  final int? selectedRow;

  /// The deleted row
  final int? deletedRow;

  /// All column definitions in this dataBook
  final List<ChangedColumn>? changedColumns;

  /// Name of all changed columns, only not null if [changedValues] is provided
  final List<String>? changedColumnNames;

  /// Values of all changed Columns, corresponds to [changedColumnNames] order
  final List<dynamic>? changedValues;

  /// If data book is readOnly
  final bool? readOnly;

  /// If data book allows deletion of the current row.
  final bool? deleteEnabled;

  /// If data book allows deletion of any row.
  final bool? modelDeleteEnabled;

  /// If data book allows update of the current row.
  final bool? updateEnabled;

  /// If data book allows update of any row.
  final bool? modelUpdateEnabled;

  /// If data book allows insertion of the current row.
  final bool? insertEnabled;

  /// If data book allows insertion of any row.
  final bool? modelInsertEnabled;

  /// The tree path
  final List<int>? treePath;

  /// The selected column
  final String? selectedColumn;

  /// The changed sort definitions
  final SortList? sortDefinitions;

  /// The cell formats for this dataprovider.
  final Map<String, RecordFormat>? recordFormats;

  /// Saves which records are read only and which are not.
  final List<List<dynamic>>? recordReadOnly;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DalDataProviderChangedResponse.fromJson(super.json)
      : dataProvider = json[ApiObjectProperty.dataProvider],
        reload = json[ApiObjectProperty.reload],
        changedColumns =
            (json[ApiObjectProperty.changedColumns] as List<dynamic>?)?.map((e) => ChangedColumn.fromJson(e)).toList(),
        selectedRow = json[ApiObjectProperty.selectedRow],
        deletedRow = json[ApiObjectProperty.deletedRow],
        changedColumnNames = json[ApiObjectProperty.changedColumnNames]?.cast<String>(),
        changedValues = json[ApiObjectProperty.changedValues],
        deleteEnabled = json[ApiObjectProperty.deleteEnabled],
        insertEnabled = json[ApiObjectProperty.insertEnabled],
        updateEnabled = json[ApiObjectProperty.updateEnabled],
        modelDeleteEnabled = json[ApiObjectProperty.modelDeleteEnabled],
        modelInsertEnabled = json[ApiObjectProperty.modelInsertEnabled],
        modelUpdateEnabled = json[ApiObjectProperty.modelUpdateEnabled],
        readOnly = json[ApiObjectProperty.readOnly],
        treePath = cast<List<int>?>(json[ApiObjectProperty.treePath]),
        selectedColumn = json[ApiObjectProperty.selectedColumn],
        recordFormats = json[ApiObjectProperty.recordFormat] != null
            ? (json[ApiObjectProperty.recordFormat] as Map<String, dynamic>).map((componentName, recordFormatJson) =>
                MapEntry(componentName, RecordFormat.fromJson(recordFormatJson, 0)))
            : null,
        recordReadOnly = json[ApiObjectProperty.recordReadOnly] != null
            ? List.from(json[ApiObjectProperty.recordReadOnly][ApiObjectProperty.records])
            : null,
        sortDefinitions = SortList.fromList((json[ApiObjectProperty.sortDefinition] as List<dynamic>?)?.map((e) => SortDefinition.fromJson(e)).toList()),
        super.fromJson();
}

class ChangedColumn {
  String name;
  String? label;
  bool? readOnly;
  bool? movable;
  bool? sortable;
  Map<String, dynamic>? cellEditorJson;

  ChangedColumn.fromJson(Map<String, dynamic> json)
      : name = json[ApiObjectProperty.name],
        label = json[ApiObjectProperty.label],
        readOnly = json[ApiObjectProperty.readOnly],
        movable = json[ApiObjectProperty.movable],
        sortable = json[ApiObjectProperty.sortable],
        cellEditorJson = json[ApiObjectProperty.cellEditor];
}
