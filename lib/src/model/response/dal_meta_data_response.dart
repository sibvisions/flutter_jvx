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
import 'api_response.dart';

class DalMetaDataResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// All column definitions in this dataBook
  List<ColumnDefinition> columns;

  /// All visible columns of this this dataBook if shown in a table
  List<String> columnViewTable;

  /// The path to the dataBook
  String dataProvider;

  /// If the databook is readonly.
  bool readOnly;

  /// If deletion is allowed.
  bool deleteEnabled;

  /// If updating a row is allowed.
  bool updateEnabled;

  /// If inserting a row is allowed.
  bool insertEnabled;

  /// The primary key columns of the dataBook
  List<String> primaryKeyColumns;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DalMetaDataResponse.fromJson(super.json)
      : columnViewTable = json[ApiObjectProperty.columnViewTable].cast<String>(),
        columns = (json[ApiObjectProperty.columns] as List<dynamic>).map((e) => ColumnDefinition.fromJson(e)).toList(),
        dataProvider = json[ApiObjectProperty.dataProvider],
        readOnly = json[ApiObjectProperty.readOnly] ?? false,
        deleteEnabled = json[ApiObjectProperty.deleteEnabled] ?? true,
        updateEnabled = json[ApiObjectProperty.updateEnabled] ?? true,
        insertEnabled = json[ApiObjectProperty.insertEnabled] ?? true,
        primaryKeyColumns = List<String>.from(json[ApiObjectProperty.primaryKeyColumns] ?? []),
        super.fromJson();
}
