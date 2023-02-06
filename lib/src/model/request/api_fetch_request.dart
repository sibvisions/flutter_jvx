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
import 'session_request.dart';

class ApiFetchRequest extends SessionRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final List<String>? columnNames;

  final bool includeMetaData;

  final int fromRow;

  final int rowCount;

  final String dataProvider;

  /// The page key if we fetch a specific page.
  final String? pageKey;

  /// If `true`, the data provider will be reloaded server side.
  bool reload;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiFetchRequest({
    required this.fromRow,
    required this.rowCount,
    required this.dataProvider,
    required this.includeMetaData,
    this.columnNames,
    this.pageKey,
    this.reload = false,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.columnNames: columnNames,
        ApiObjectProperty.includeMetaData: includeMetaData,
        ApiObjectProperty.fromRow: fromRow,
        ApiObjectProperty.rowCount: rowCount,
        ApiObjectProperty.dataProvider: dataProvider,
        ApiObjectProperty.reload: reload,
      };
}
