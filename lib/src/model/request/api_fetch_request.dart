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
import '../command/api/fetch_command.dart';
import 'api_filter_request.dart';
import 'filter.dart';
import 'session_request.dart';

class ApiFetchRequest extends SessionRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Data provider to fetch the data from.
  final String dataProvider;

  // unused
  /// Column names to fetch.
  //final List<String>? columnNames;

  /// Filter of this fetch. This is only used for tree/page fetches.
  /// For normal fetches, the filter is should be set with [ApiFilterRequest]
  final Filter? filter;

  /// If `true`, the meta data will be included.
  final bool includeMetaData;

  /// The row number to start fetching from.
  final int fromRow;

  /// The row count to fetch.
  final int rowCount;

  /// If `true`, the data provider will be reloaded server side.
  bool reload;

  final FetchCommand? command;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiFetchRequest({
    required this.fromRow,
    required this.rowCount,
    required this.dataProvider,
    required this.includeMetaData,
    this.filter,
    this.reload = false,
    this.command,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.includeMetaData: includeMetaData,
        ApiObjectProperty.fromRow: fromRow,
        ApiObjectProperty.rowCount: rowCount,
        ApiObjectProperty.dataProvider: dataProvider,
        ApiObjectProperty.reload: reload,
        ApiObjectProperty.filter: filter?.toJson(),
      };
}
