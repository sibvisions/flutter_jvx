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

import '../../../../../service/api/shared/api_object_property.dart';

class ColumnMap {
  List<String> columnNames = <String>[];
  List<String> referencedColumnNames = <String>[];

  ColumnMap();

  ColumnMap.fromJson(Map<String, dynamic> json) {
    var jsonColumnNames = json[ApiObjectProperty.columnNames];
    if (jsonColumnNames != null) {
      columnNames = List<String>.from(jsonColumnNames);
    }
    var jsonReferencedColumnNames = json[ApiObjectProperty.referencedColumnNames];
    if (jsonReferencedColumnNames != null) {
      referencedColumnNames = List<String>.from(jsonReferencedColumnNames);
    }
  }

  String? getColumnName(String? pReferencedColumnName) {
    if (pReferencedColumnName == null) {
      return null;
    }
    var index = referencedColumnNames.indexOf(pReferencedColumnName);
    if (index == -1) {
      return null;
    }
    return columnNames[index];
  }

  String? getReferencedColumnName(String? pColumnName) {
    if (pColumnName == null) {
      return null;
    }
    var index = columnNames.indexOf(pColumnName);
    if (index == -1) {
      return null;
    }
    return referencedColumnNames[index];
  }

  Map<String, dynamic> toJson() => {
        "columnNames": columnNames,
        "referencedColumnNames": referencedColumnNames,
      };
}
