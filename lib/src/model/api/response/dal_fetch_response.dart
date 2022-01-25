import '../api_object_property.dart';
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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Creates an [DalFetchResponse] Object
  DalFetchResponse(
      {required String name,
      required this.dataProvider,
      required this.from,
      required this.selectedRow,
      required this.isAllFetched,
      required this.columnNames,
      required this.to,
      required this.records})
      : super(name: name);

  /// Parses a json into an [DalFetchResponse] Object
  DalFetchResponse.fromJson(Map<String, dynamic> pJson)
      : records = pJson[ApiObjectProperty.records].cast<List<dynamic>>(),
        to = pJson[ApiObjectProperty.to],
        from = pJson[ApiObjectProperty.from],
        columnNames = pJson[ApiObjectProperty.columnNames].cast<String>(),
        isAllFetched = pJson[ApiObjectProperty.isAllFetched],
        selectedRow = pJson[ApiObjectProperty.selectedRow],
        dataProvider = pJson[ApiObjectProperty.dataProvider],
        super.fromJson(pJson);
}
