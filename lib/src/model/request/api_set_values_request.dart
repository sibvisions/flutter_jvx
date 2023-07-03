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
import 'filter.dart';
import 'session_request.dart';

/// Request to set the value of a data-bound component
class ApiSetValuesRequest extends SessionRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// DataRow or DataProvider of the component
  final String dataProvider;

  /// List of columns, order of which corresponds to order of values list
  final List<String> columnNames;

  /// List of values, order of which corresponds to order of columnsName list
  final List<dynamic> values;

  /// The column the server has to check against if it is readOnly.
  final String? editorColumnName;

  /// Filter of this setValues, used in table to edit non selected rows.
  final Filter? filter;

  /// The row number to shortcut the filter.
  /// This row index will be checked if the filter applies, otherwise checks every row until the filter applies.
  final int? rowNumber;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiSetValuesRequest({
    required this.dataProvider,
    required this.columnNames,
    required this.values,
    this.filter,
    this.rowNumber,
    this.editorColumnName,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.dataProvider: dataProvider,
        ApiObjectProperty.columnNames: columnNames,
        ApiObjectProperty.values: values,
        if (filter != null) ApiObjectProperty.filter: filter?.toJson(),
        if (rowNumber != null) ApiObjectProperty.rowNumber: rowNumber,
        if (editorColumnName != null) ApiObjectProperty.editorColumnName: editorColumnName,
      };
}
