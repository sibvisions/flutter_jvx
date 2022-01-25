import '../api_object_property.dart';
import 'api_response.dart';
import '../../data/column_definition.dart';
import '../../../../util/parse_util.dart';

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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DalMetaDataResponse(
      {required String name, required this.dataProvider, required this.columns, required this.columnViewTable})
      : super(name: name);

  DalMetaDataResponse.fromJson({required Map<String, dynamic> pJson})
      : columnViewTable = pJson[ApiObjectProperty.columnViewTable].cast<String>(),
        columns = ParseUtil.parseColumnDefinitions(pJson[ApiObjectProperty.columns]),
        dataProvider = pJson[ApiObjectProperty.dataProvider],
        super.fromJson(pJson);
}
