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

import '../../data/filter_condition.dart';
import '../../request/filter.dart';
import 'dal_command.dart';

/// The command for record filtering.
class FilterCommand extends DalCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// A simple filter to apply
  final Filter? filter;

  /// A complex filter to apply
  final FilterCondition? filterCondition;

  /// The editor component id to filter by value
  final String? editorComponentId;

  /// The value to filter by
  final String? value;

  /// The column names to filter by
  final List<String>? columnNames;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FilterCommand({
    required super.dataProvider,
    this.filter,
    this.filterCondition,
    super.showLoading,
    required super.reason,
  })  : editorComponentId = null,
        value = null,
        columnNames = null,
        assert(
          (filter == null) || (filterCondition == null),
          "Only either filter or filterCondition is to be provided",
        );

  FilterCommand.none({
    required super.dataProvider,
    this.editorComponentId,
    super.showLoading,
    required super.reason,
  })  : filter = null,
        filterCondition = null,
        value = null,
        columnNames = null;

  FilterCommand.byValue({
    required super.dataProvider,
    required this.editorComponentId,
    required this.value,
    required this.columnNames,
    super.showLoading,
    required super.reason,
  })  : filter = null,
        filterCondition = null;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "FilterCommand{editorComponentId: $editorComponentId, value: $value, columnNames: $columnNames, filter: $filter, filterCondition: $filterCondition, ${super.toString()}}";
  }
}
