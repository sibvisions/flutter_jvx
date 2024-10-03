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
import '../../util/column_list.dart';
import '../component/editor/cell_editor/linked/reference_definition.dart';
import '../data/column_definition.dart';
import 'api_response.dart';

class DalMetaDataResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The reference of this response
  ReferenceDefinition? masterReference;

  /// The detail references of this data book.
  List<ReferenceDefinition>? detailReferences;

  /// The master reference of this data book.
  ReferenceDefinition? rootReference;

  /// All column definitions in this data book
  ColumnList? columnDefinitions;

  /// All visible columns of this this data book if shown in a table
  List<String>? columnViewTable;

  /// All visible columns of this this data book if shown in a tree
  List<String>? columnViewTree = [];

  /// The path to the dataBook
  String dataProvider;

  /// If the databook is readonly.
  bool? readOnly;

  /// If data book allows deletion of the current row.
  bool? deleteEnabled;

  /// If data book allows deletion of any row.
  bool? modelDeleteEnabled;

  /// If data book allows update of the current row.
  bool? updateEnabled;

  /// If data book allows update of any row.
  bool? modelUpdateEnabled;

  /// If data book allows insertion of the current row.
  bool? insertEnabled;

  /// If data book allows insertion of any row.
  bool? modelInsertEnabled;

  /// The primary key columns of the dataBook
  List<String>? primaryKeyColumns;

  /// If the row 0 is an additional row (Not deletable)
  bool? additionalRowVisible;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DalMetaDataResponse.fromJson(super.json)
      : dataProvider = json[ApiObjectProperty.dataProvider],
        columnViewTable = json[ApiObjectProperty.columnViewTable]?.cast<String>(),
        columnViewTree = json[ApiObjectProperty.columnViewTree]?.cast<String>(),
        columnDefinitions = ColumnList.fromList((json[ApiObjectProperty.columns] as List<dynamic>?)?.map((e) => ColumnDefinition.fromJson(e)).toList()),
        readOnly = json[ApiObjectProperty.readOnly],
        deleteEnabled = json[ApiObjectProperty.deleteEnabled],
        updateEnabled = json[ApiObjectProperty.updateEnabled],
        insertEnabled = json[ApiObjectProperty.insertEnabled],
        modelDeleteEnabled = json[ApiObjectProperty.modelDeleteEnabled],
        modelInsertEnabled = json[ApiObjectProperty.modelInsertEnabled],
        modelUpdateEnabled = json[ApiObjectProperty.modelUpdateEnabled],
        primaryKeyColumns = json[ApiObjectProperty.primaryKeyColumns]?.cast<String>(),
        masterReference = json[ApiObjectProperty.masterReference] != null
            ? ReferenceDefinition.fromJson(json[ApiObjectProperty.masterReference])
            : null,
        detailReferences = (json[ApiObjectProperty.detailReferences] as List<dynamic>?)?.map((e) => ReferenceDefinition.fromJson(e)).toList(),
        rootReference = json[ApiObjectProperty.rootReference] != null
            ? ReferenceDefinition.fromJson(json[ApiObjectProperty.rootReference])
            : null,
        additionalRowVisible = json[ApiObjectProperty.additionalRowVisible],
        super.fromJson();
}
