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

class SortDefinition {
  /// The column name to sort by
  String columnName;

  /// The sort mode to sort by.
  SortMode? mode;

  SortDefinition({required this.columnName, this.mode = SortMode.ascending});

  SortDefinition.fromJson(Map<String, dynamic> pJson)
      : columnName = pJson[ApiObjectProperty.columnName],
        mode = _parseSortMode(pJson[ApiObjectProperty.mode]);

  SortMode? get nextMode {
    switch (mode) {
      case null:
        return SortMode.ascending;
      case SortMode.ascending:
        return SortMode.descending;
      case SortMode.descending:
      default:
        return null;
    }
  }

  String get _sortString {
    switch (mode) {
      case null:
        return "None";
      case SortMode.descending:
        return "Descending";
      case SortMode.ascending:
      default:
        return "Ascending";
    }
  }

  static SortMode? _parseSortMode(String? pSortMode) {
    switch (pSortMode) {
      case null:
        return null;
      case "Descending":
        return SortMode.descending;
      case "Ascending":
      default:
        return SortMode.ascending;
    }
  }

  Map<String, dynamic> toJson() => {
        ApiObjectProperty.columnName: columnName,
        ApiObjectProperty.mode: _sortString,
      };
}

enum SortMode { ascending, descending }
