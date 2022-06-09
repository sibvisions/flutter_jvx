import '../../../../util/parse_util.dart';
import '../../data/column_definition.dart';
import '../api_object_property.dart';
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

  DalMetaDataResponse({
    required String name,
    required this.dataProvider,
    required this.columns,
    required this.columnViewTable,
    required this.readOnly,
    required this.deleteEnabled,
    required this.updateEnabled,
    required this.insertEnabled,
    required this.primaryKeyColumns,
  }) : super(name: name);

  DalMetaDataResponse.fromJson({required Map<String, dynamic> pJson})
      : columnViewTable = pJson[ApiObjectProperty.columnViewTable].cast<String>(),
        columns = ParseUtil.parseColumnDefinitions(pJson[ApiObjectProperty.columns]),
        dataProvider = pJson[ApiObjectProperty.dataProvider],
        readOnly = pJson[ApiObjectProperty.readOnly] ?? false,
        deleteEnabled = pJson[ApiObjectProperty.deleteEnabled] ?? true,
        updateEnabled = pJson[ApiObjectProperty.updateEnabled] ?? true,
        insertEnabled = pJson[ApiObjectProperty.insertEnabled] ?? true,
        primaryKeyColumns = List<String>.from(pJson[ApiObjectProperty.primaryKeyColumns] ?? []),
        super.fromJson(pJson);
}
