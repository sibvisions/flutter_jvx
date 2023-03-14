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

class LinkReference {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The column names of the current data book.
  List<String> columnNames = <String>[];

  /// The column names of the referenced data book.
  List<String> referencedColumnNames = <String>[];

  /// The name of the referenced data book.
  late String referencedDataprovider;

  // The map to convert specific strings to other strings for linked cell editors.
  Map<String, String> dataToDisplay = {};

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  LinkReference();

  LinkReference.fromJson(Map<String, dynamic> json) {
    var jsonColumnNames = json[ApiObjectProperty.columnNames];
    if (jsonColumnNames != null) {
      columnNames = List<String>.from(jsonColumnNames);
    }
    var jsonReferencedColumnNames = json[ApiObjectProperty.referencedColumnNames];
    if (jsonReferencedColumnNames != null) {
      referencedColumnNames = List<String>.from(jsonReferencedColumnNames);
    }
    var jsonReferencedDataBook = json[ApiObjectProperty.referencedDataBook];
    if (jsonReferencedDataBook != null) {
      referencedDataprovider = jsonReferencedDataBook;
    }
  }

  Map<String, dynamic> toJson() => {
        "columnNames": columnNames,
        "referencedColumnNames": referencedColumnNames,
        "referencedDataBook": referencedDataprovider,
      };
}
