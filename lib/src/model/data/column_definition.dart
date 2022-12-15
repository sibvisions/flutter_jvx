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
import '../../util/parse_util.dart';
import '../layout/alignments.dart';
import '../response/dal_meta_data_response.dart';

/// The definition of a column of a dataBook. Received from the server in a [DalMetaDataResponse]
class ColumnDefinition {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the column
  final String name;

  /// Identifier of the columns datatype
  final int dataTypeIdentifier;

  /// Label of the column
  final String label;

  /// If this column is nullable
  final bool nullable;

  /// The comment of this ColumnDefinition
  final String comment = "";

  /// If this column is readonly
  final bool readonly;

  /// If this column is writeable
  final bool writeable = true;

  /// If this column is filterable
  final bool filterable = true;

  /// Width of the column in a table
  final double? width;

  /// If it is allowed to resize this column if present in a table
  final bool resizable;

  /// If it is allowed to sort by this column if present in a table
  final bool sortable;

  /// If it is allowed to move this column if present in a table
  final bool movable;

  /// The cell editor json of this column.
  late final Map<String, dynamic> cellEditorJson;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Datatype specific information
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The length of the datatype.
  final int? length;

  /// If zero or positive, the scale is the number of digits to the right of the decimal point. If negative, the unscaled value of the number is multiplied by ten to the power of the negation of the scale. For example, a scale of -3 means the unscaled value is multiplied by 1000.
  final int? scale;

  /// The precision is the number of digits in the unscaled value. For instance, for the number 123.45, the precision returned is 5.
  final int? precision;

  /// If the number type is signed.
  final bool? signed;

  /// Enable autotrim to avoid whitespaces at the begin and end of texts
  final bool autoTrim;

  /// The encoding of binary data types.
  final String encoding;

  /// The fractional seconds precision.
  final int iFractionalSecondsPrecision;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  String? get cellEditorClassName => cellEditorJson[ApiObjectProperty.className];

  HorizontalAlignment get cellEditorHorizontalAlignment {
    return ParseUtil.getPropertyValue(
      pJson: cellEditorJson,
      pKey: ApiObjectProperty.horizontalAlignment,
      pDefault: HorizontalAlignment.LEFT,
      pCurrent: HorizontalAlignment.LEFT,
      pCondition: (pValue) => pValue < HorizontalAlignment.values.length && pValue >= 0,
      pConversion: HorizontalAlignmentE.fromDynamic,
    );
  }

  /// Parse a json list of column definitions into a list of [ColumnDefinition] objects.
  ColumnDefinition.fromJson(Map<String, dynamic> pJson)
      : name = pJson[ApiObjectProperty.name] ?? "",
        label = pJson[ApiObjectProperty.label] ?? "",
        dataTypeIdentifier = pJson[ApiObjectProperty.dataTypeIdentifier] ?? 0,
        width = pJson[ApiObjectProperty.width] != 0 ? (pJson[ApiObjectProperty.width] as int).toDouble() : null,
        readonly = pJson[ApiObjectProperty.readOnly] ?? true,
        nullable = pJson[ApiObjectProperty.nullable] ?? true,
        resizable = pJson[ApiObjectProperty.resizable] ?? true,
        sortable = pJson[ApiObjectProperty.sortable] ?? false,
        movable = pJson[ApiObjectProperty.movable] ?? false,
        length = pJson[ApiObjectProperty.length],
        scale = pJson[ApiObjectProperty.scale],
        precision = pJson[ApiObjectProperty.precision],
        signed = pJson[ApiObjectProperty.signed],
        autoTrim = pJson[ApiObjectProperty.autoTrim] ?? false,
        iFractionalSecondsPrecision = pJson[ApiObjectProperty.fractionalSecondsPrecision] ?? 0,
        cellEditorJson = pJson[ApiObjectProperty.cellEditor],
        encoding = pJson[ApiObjectProperty.encoding] ?? "";
}
