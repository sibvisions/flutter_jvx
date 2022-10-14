import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

class DalFetchResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// List of all Columns names present in fetch, order is important
  final List<String> columnNames;

  /// Fetch data in this response are from this index.
  final int from;

  /// Fetch data in this response are to this index.
  final int to;

  /// Selected row of this dataBook.
  final int selectedRow;

  /// True if all data for this dataBook have been fetched
  final bool isAllFetched;

  /// Link to the connected dataBook
  final String dataProvider;

  /// Fetched records
  final List<List<dynamic>> records;

  /// Clear data before filling
  final bool clear;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Creates an [DalFetchResponse] Object
  DalFetchResponse({
    required this.dataProvider,
    required this.from,
    required this.selectedRow,
    required this.isAllFetched,
    required this.columnNames,
    required this.to,
    required this.records,
    this.clear = false,
    required super.name,
    required super.originalRequest,
  });

  /// Parses a json into an [DalFetchResponse] Object
  DalFetchResponse.fromJson(super.json, super.originalRequest)
      : records = json[ApiObjectProperty.records].cast<List<dynamic>>(),
        to = json[ApiObjectProperty.to],
        from = json[ApiObjectProperty.from],
        columnNames = json[ApiObjectProperty.columnNames].cast<String>(),
        isAllFetched = json[ApiObjectProperty.isAllFetched] ?? false,
        selectedRow = json[ApiObjectProperty.selectedRow],
        dataProvider = json[ApiObjectProperty.dataProvider],
        clear = json[ApiObjectProperty.clear] ?? false,
        super.fromJson();
}
