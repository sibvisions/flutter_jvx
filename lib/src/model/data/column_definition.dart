import '../api/api_object_property.dart';
import '../api/response/dal_meta_data_response.dart';

/// The definition of a column of a dataBook. Received from the server in a [DalMetaDataResponse]
class ColumnDefinition {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the column
  String name = "";

  /// Label of the column
  String label = "";

  /// Identifier of the columns datatype
  int dataTypeIdentifier = 0;

  /// Width of the column in a table
  double? width;

  /// If this column is readonly
  bool readonly = true;

  /// If this column is nullable
  bool nullable = true;

  /// If it is allowed to resize this column if present in a table
  bool resizable = true;

  /// If it is allowed to sort by this column if present in a table
  bool sortable = false;

  bool movable = true;

  /// CellEditor info for this column
  //late ICellEditor cellEditor;

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
    // var jsonCellEditor = pJson[ApiObjectProperty.cellEditor];
    // if (jsonCellEditor != null) {
    //   cellEditor =
    //       ICellEditor.getCellEditor(pCellEditorJson: jsonCellEditor, onChange: onChange, onEndEditing: onEndEditing);
    // }
  }

  void onChange(dynamic value) {}

  void onEndEditing(dynamic value) {}
}
