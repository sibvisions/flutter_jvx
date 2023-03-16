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
import '../data/column_definition.dart';
import '../data/data_book.dart';
import 'api_response.dart';

class DalMetaDataResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The reference of this response
  ReferenceDefinition? masterReference;

  /// The master reference of this databook.
  ReferenceDefinition? detailReference;

  /// The master reference of this databook.
  ReferenceDefinition? rootReference;

  /// All column definitions in this dataBook
  List<ColumnDefinition>? columns;

  /// All visible columns of this this dataBook if shown in a table
  List<String>? columnViewTable;

  /// All visible columns of this this dataBook if shown in a tree
  List<String>? columnViewTree = [];

  /// The path to the dataBook
  String dataProvider;

  /// If the databook is readonly.
  bool? readOnly;

  /// If deletion is allowed.
  bool? deleteEnabled;

  /// If updating a row is allowed.
  bool? updateEnabled;

  /// If inserting a row is allowed.
  bool? insertEnabled;

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
        columns =
            (json[ApiObjectProperty.columns] as List<dynamic>?)?.map((e) => ColumnDefinition.fromJson(e)).toList(),
        readOnly = json[ApiObjectProperty.readOnly],
        deleteEnabled = json[ApiObjectProperty.deleteEnabled],
        updateEnabled = json[ApiObjectProperty.updateEnabled],
        insertEnabled = json[ApiObjectProperty.insertEnabled],
        primaryKeyColumns = json[ApiObjectProperty.primaryKeyColumns]?.cast<String>(),
        masterReference = json[ApiObjectProperty.masterReference] != null
            ? ReferenceDefinition.fromJson(json[ApiObjectProperty.masterReference])
            : null,
        detailReference = json[ApiObjectProperty.detailReference] != null
            ? ReferenceDefinition.fromJson(json[ApiObjectProperty.detailReference])
            : null,
        rootReference = json[ApiObjectProperty.rootReference] != null
            ? ReferenceDefinition.fromJson(json[ApiObjectProperty.rootReference])
            : null,
        additionalRowVisible = json[ApiObjectProperty.additionalRowVisible],
        super.fromJson();
}
