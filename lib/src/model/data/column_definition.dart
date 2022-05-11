import 'package:flutter_client/src/components/editor/cell_editor/fl_dummy_cell_editor.dart';
import 'package:flutter_client/src/components/editor/cell_editor/i_cell_editor.dart';

import '../api/api_object_property.dart';
import '../api/response/dal_meta_data_response.dart';

/// The definition of a column of a dataBook. Received from the server in a [DalMetaDataResponse]
class ColumnDefinition {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the column
  String name = "";

  /// Identifier of the columns datatype
  int dataTypeIdentifier = 0;

  /// Label of the column
  String label = "";

  /// The default label of the ColumnDefinition
  String sDefaultLabel = "";

  /// If this column is nullable
  bool nullable = true;

  /// The comment of this ColumnDefinition
  String comment = "";

  /// The default value of this ColumnDefinition
  dynamic defaultObject;

  /// The default value of this ColumnDefinition
  List<dynamic> defaultValues = [];

  /// If this column is readonly
  bool readonly = true;

  /// If this column is readonly
  bool writeable = true;

  /// If this column is readonly
  bool filterable = true;

  /// Width of the column in a table
  double? width;

  /// If it is allowed to resize this column if present in a table
  bool resizable = true;

  /// If it is allowed to sort by this column if present in a table
  bool sortable = false;

  /// If it is allowed to move this column if present in a table
  bool movable = true;

  /// The cell editor of this column.
  ICellEditor cellEditor = FlDummyCellEditor();

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
  bool autoTrim = false;

  /// The encoding of binary data types.
  String encoding = "";

  /// The fractional seconds precision.
  int iFractionalSecondsPrecision = 0;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns an instance of an [ColumnDefinition] with default values.
  ColumnDefinition();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Writes all data present in the json into the objects properties.
  void applyFromJson({required Map<String, dynamic> pJson}) {
    // Name
    var jsonName = pJson[ApiObjectProperty.name];
    if (jsonName != null) {
      name = jsonName;
    }
    // Label
    var jsonLabel = pJson[ApiObjectProperty.label];
    if (jsonLabel != null) {
      label = jsonLabel;
    }
    // DataTypeIdentifier
    var jsonDataTypeIdentifier = pJson[ApiObjectProperty.dataTypeIdentifier];
    if (jsonDataTypeIdentifier != null) {
      dataTypeIdentifier = jsonDataTypeIdentifier;
    }
    // Width
    var jsonWidth = pJson[ApiObjectProperty.width];
    if (jsonWidth != null) {
      width = (jsonWidth as int).toDouble();
    }
    // Readonly
    var jsonReadonly = pJson[ApiObjectProperty.readOnly];
    if (jsonReadonly != null) {
      readonly = jsonReadonly;
    }
    // Nullable
    var jsonNullable = pJson[ApiObjectProperty.nullable];
    if (jsonNullable != null) {
      nullable = jsonNullable;
    }
    // Resizable
    var jsonResizable = pJson[ApiObjectProperty.resizable];
    if (jsonResizable != null) {
      resizable = jsonResizable;
    }
    // Sortable
    var jsonSortable = pJson[ApiObjectProperty.sortable];
    if (jsonSortable != null) {
      sortable = jsonSortable;
    }
    // Movable
    var jsonMovable = pJson[ApiObjectProperty.movable];
    if (jsonMovable != null) {
      movable = jsonMovable;
    }

    var jsonLength = pJson[ApiObjectProperty.length];
    if (jsonLength != null) {
      length = jsonLength;
    }

    var jsonScale = pJson[ApiObjectProperty.scale];
    if (jsonScale != null) {
      scale = jsonScale;
    }

    var jsonPrecision = pJson[ApiObjectProperty.precision];
    if (jsonPrecision != null) {
      precision = jsonPrecision;
    }

    var jsonSigned = pJson[ApiObjectProperty.signed];
    if (jsonSigned != null) {
      signed = jsonSigned;
    }

    var jsonAutoTrim = pJson[ApiObjectProperty.autoTrim];
    if (jsonAutoTrim != null) {
      autoTrim = jsonAutoTrim;
    }

    var jsonEncoding = pJson[ApiObjectProperty.encoding];
    if (jsonEncoding != null) {
      encoding = jsonEncoding;
    }

    var jsonFractionalSecondsPrecision = pJson[ApiObjectProperty.fractionalSecondsPrecision];
    if (jsonFractionalSecondsPrecision != null) {
      iFractionalSecondsPrecision = jsonFractionalSecondsPrecision;
    }
  }

  void onChange(dynamic value) {}

  void onEndEditing(dynamic value) {}
}
