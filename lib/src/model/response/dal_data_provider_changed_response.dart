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

import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

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

  /// If data book has deletion enabled
  final bool? deleteEnabled;

  /// If data book has update enabled
  final bool? updateEnabled;

  /// If data book has insert enabled
  final bool? insertEnabled;

  /// The tree path, TODO implement treePath
  final List<int>? treePath;

  /// The selected column, TODO implement selected column
  final String? selectedColumn;

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
        changedColumnNames = json[ApiObjectProperty.changedColumnNames] != null
            ? List<String>.from(json[ApiObjectProperty.changedColumnNames])
            : null,
        changedValues = json[ApiObjectProperty.changedValues],
        deleteEnabled = json[ApiObjectProperty.deleteEnabled],
        insertEnabled = json[ApiObjectProperty.insertEnabled],
        readOnly = json[ApiObjectProperty.readOnly],
        updateEnabled = json[ApiObjectProperty.updateEnabled],
        treePath = json[ApiObjectProperty.treePath],
        selectedColumn = json[ApiObjectProperty.selectedColumn],
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
