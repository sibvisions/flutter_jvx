/* Copyright 2022 SIB Visions GmbH
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

import '../../service/api/shared/api_object_property.dart';
import '../data/filter_condition.dart';

class Filter {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the column from the value
  final List<String> columnNames;

  final List<dynamic> values;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Filter({
    required this.columnNames,
    required this.values,
  });

  Filter.empty()
      : columnNames = [],
        values = [];

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Map<String, dynamic> toJson() => {
        ApiObjectProperty.columnNames: columnNames,
        ApiObjectProperty.values: values,
      };

  bool get isEmpty => columnNames.isEmpty && values.isEmpty;

  Map<String, dynamic> asMap() {
    return Map.fromEntries(columnNames.mapIndexed(
      (index, element) => MapEntry(element, values[index]),
    ));
  }

  /// Returns this filter as list of filter conditions
  List<FilterCondition> asFilterConditions() => asMap()
      .entries
      .map((entry) => FilterCondition(
            columnName: entry.key,
            value: entry.value,
            compareType: CompareType.EQUALS,
          ))
      .toList();
}
