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

class ColumnView {
  List<String> columnNames = <String>[];
  int? columnCount;
  List? rowDefinitions;

  ColumnView();

  ColumnView.fromJson(Map<String, dynamic> json) {
    var jsonColumnNames = json[ApiObjectProperty.columnNames];
    if (jsonColumnNames != null) {
      columnNames = List<String>.from(jsonColumnNames);
    }

    var jsonColumnCount = json[ApiObjectProperty.columnCount];
    if (jsonColumnCount != null) {
      columnCount = jsonColumnCount;
    }

    var jsonRowDefinitions = json[ApiObjectProperty.rowDefinitions];
    if (jsonRowDefinitions != null) {
      rowDefinitions = List.from(jsonRowDefinitions);
    }
  }

  Map<String, dynamic> toJson() =>
      <String, dynamic>{"columnNames": columnNames, "columnCount": columnCount, "rowDefinitions": rowDefinitions};
}
