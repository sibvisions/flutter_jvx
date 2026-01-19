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

import '../../../../../../service/api/shared/api_object_property.dart';
import 'base_condition.dart';

class CompareCondition extends BaseCondition {
  /// The data row to use for the compare.
  final String? dataRow;

  /// The column name in the [dataRow] to use for the compare.
  final String dataRowColumnName;

  /// The column to use for the compare.
  final String columnName;

  /// Determines, if null values will be ignored.
  final bool ignoreNull;

  /// The value to use for the compare.
  final Object value;

  CompareCondition(
    super.type,
    this.dataRow,
    this.dataRowColumnName,
    this.columnName,
    this.ignoreNull,
    this.value,
  );

  CompareCondition.fromJson(super.json)
      : dataRow = json[ApiObjectProperty.dataRow],
        dataRowColumnName = json[ApiObjectProperty.dataRowColumnName],
        columnName = json[ApiObjectProperty.columnName],
        ignoreNull = json[ApiObjectProperty.ignoreNull],
        value = json[ApiObjectProperty.value],
        super.fromJson();
}
