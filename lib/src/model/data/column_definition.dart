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
import '../../service/config/config_controller.dart';
import '../../util/parse_util.dart';
import '../component/editor/cell_editor/cell_editor_model.dart';
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
  int dataTypeIdentifier;

  /// Label of the column
  String label;

  /// If this column is nullable
  bool nullable;

  /// The comment of this ColumnDefinition
  String comment = "";

  /// If this column is readonly
  bool readOnly;

  /// If this column is writeable
  bool writeable = true;

  /// If this column is filterable
  bool filterable = true;

  /// Width of the column in a table
  double? width;

  /// If it is allowed to resize this column if present in a table
  bool resizable;

  /// If it is allowed to sort by this column if present in a table
  bool sortable;

  /// If it is allowed to move this column if present in a table
  bool movable;

  /// The cell editor json of this column.
  Map<String, dynamic> cellEditorJson;

  /// The cell editor of this column.
  ICellEditorModel cellEditorModel;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Datatype specific information
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The length of the datatype.
  int? length;

  /// If zero or positive, the scale is the number of digits to the right of the decimal point. If negative, the unscaled value of the number is multiplied by ten to the power of the negation of the scale. For example, a scale of -3 means the unscaled value is multiplied by 1000.
  int? scale;

  /// The precision is the number of digits in the unscaled value. For instance, for the number 123.45, the precision returned is 5.
  int? precision;

  /// If the number type is signed.
  bool? signed;

  /// Enable autotrim to avoid whitespaces at the begin and end of texts
  bool autoTrim;

  /// The encoding of binary data types.
  String encoding;

  /// The fractional seconds precision.
  int iFractionalSecondsPrecision;

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
  ColumnDefinition.fromJson(Map<String, dynamic> json)
      : name = json[ApiObjectProperty.name] ?? "",
        label = json[ApiObjectProperty.label] ?? "",
        dataTypeIdentifier = json[ApiObjectProperty.dataTypeIdentifier] ?? 0,
        width = json[ApiObjectProperty.width] != 0
            ? (json[ApiObjectProperty.width] as int).toDouble() * ConfigController().getScaling()
            : null,
        readOnly = json[ApiObjectProperty.readOnly] ?? true,
        nullable = json[ApiObjectProperty.nullable] ?? true,
        resizable = json[ApiObjectProperty.resizable] ?? true,
        sortable = json[ApiObjectProperty.sortable] ?? false,
        movable = json[ApiObjectProperty.movable] ?? false,
        length = json[ApiObjectProperty.length],
        scale = json[ApiObjectProperty.scale],
        precision = json[ApiObjectProperty.precision],
        signed = json[ApiObjectProperty.signed],
        autoTrim = json[ApiObjectProperty.autoTrim] ?? false,
        iFractionalSecondsPrecision = json[ApiObjectProperty.fractionalSecondsPrecision] ?? 0,
        cellEditorJson = json[ApiObjectProperty.cellEditor],
        cellEditorModel = ICellEditorModel.fromJson(json[ApiObjectProperty.cellEditor]),
        encoding = json[ApiObjectProperty.encoding] ?? "";
}
