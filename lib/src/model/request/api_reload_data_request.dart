/*
 * Copyright 2025 SIB Visions GmbH
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
import '../../service/command/shared/processor/api/reload_data_processor.dart';
import '../command/api/reload_data_command.dart';
import 'application_request.dart';
import 'filter.dart';

class ApiReloadDataRequest extends ApplicationRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Data provider name
  final String dataProvider;

  /// Filter of this fetch. This is only used for tree/page fetches.
  /// For normal fetches, the filter is should be set with [ApiFilterRequest]
  final Filter? filter;

  /// The row number to start fetching from.
  final int fromRow;

  /// The row count to fetch.
  final int rowCount;

  /// Whether we don't need records in the response
  final bool withoutFetch;

  final ReloadDataCommand? command;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiReloadDataRequest({
    required this.dataProvider,
    this.fromRow = 0,
    this.rowCount = 0,
    this.withoutFetch = false,
    this.filter,
    this.command
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    ApiObjectProperty.dataProvider: dataProvider,
    ApiObjectProperty.fromRow: fromRow,
    ApiObjectProperty.rowCount: rowCount,
    ApiObjectProperty.withoutFetch: withoutFetch,
    ApiObjectProperty.filter: filter?.toJson(),
  };

}
