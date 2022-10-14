import '../../service/api/shared/api_object_property.dart';
import '../data/column_definition.dart';
import 'api_response.dart';

class DalMetaDataResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// All column definitions in this dataBook
  final List<ColumnDefinition> columns;

  /// All visible columns of this this dataBook if shown in a table
  final List<String> columnViewTable;

  /// The path to the dataBook
  final String dataProvider;

  /// If the databook is readonly.
  final bool readOnly;

  /// If deletion is allowed.
  final bool deleteEnabled;

  /// If updating a row is allowed.
  final bool updateEnabled;

  /// If inserting a row is allowed.
  final bool insertEnabled;

  /// The primary key columns of the dataBook
  final List<String> primaryKeyColumns;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DalMetaDataResponse.fromJson(super.json, super.originalRequest)
      : columnViewTable = json[ApiObjectProperty.columnViewTable].cast<String>(),
        columns = (json[ApiObjectProperty.columns] as List<dynamic>)
            .map((e) => ColumnDefinition.fromJson(e as Map<String, dynamic>))
            .toList(),
        dataProvider = json[ApiObjectProperty.dataProvider],
        readOnly = json[ApiObjectProperty.readOnly] ?? false,
        deleteEnabled = json[ApiObjectProperty.deleteEnabled] ?? true,
        updateEnabled = json[ApiObjectProperty.updateEnabled] ?? true,
        insertEnabled = json[ApiObjectProperty.insertEnabled] ?? true,
        primaryKeyColumns = List<String>.from(json[ApiObjectProperty.primaryKeyColumns] ?? []),
        super.fromJson();
}
