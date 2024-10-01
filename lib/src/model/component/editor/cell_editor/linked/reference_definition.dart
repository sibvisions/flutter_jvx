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
import 'column_mapping.dart';

class ReferenceDefinition extends ColumnMapping {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The name of the referenced data book.
  final String referencedDataBook;

  /// The map to convert specific strings to other strings for linked cell editors.
  Map<String, String> dataToDisplay = {};

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ReferenceDefinition({
    super.columnNames,
    super.referencedColumnNames,
    required this.referencedDataBook,
    Map<String, String>? dataToDisplay,
  })  : dataToDisplay = dataToDisplay ?? {};

  ReferenceDefinition.fromJson(super.json)
      : referencedDataBook = json[ApiObjectProperty.referencedDataBook],
        super.fromJson();

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.referencedDataBook: referencedDataBook,
      };
}
