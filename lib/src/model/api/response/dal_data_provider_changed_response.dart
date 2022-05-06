import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/response/api_response.dart';

class DalDataProviderChangedResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Data provider that changed
  final String dataProvider;

  /// -1 | x
  /// -1 - delete all local data and re-fetch
  /// x - re-fetch this specific row
  int? reload;

  /// New selected row
  int? selectedRow;

  /// Name of columns of the data book, only not null if [changedValues] is provided
  List<String>? columnNames;

  /// Name of all changed columns, only not null if [changedValues] is provided
  List<String>? changedColumnNames;

  /// Values of all changed Columns, corresponds to [changedColumnNames] order
  List<dynamic>? changedValues;

  /// If data book is readOnly
  bool? readOnly;

  /// If data book has deletion enabled
  bool? deleteEnabled;

  /// If data book has update enabled
  bool? updateEnabled;

  /// If data book has insert enabled
  bool? insertEnabled;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DalDataProviderChangedResponse({
    required this.dataProvider,
    this.reload,
    this.columnNames,
    this.selectedRow,
    this.changedColumnNames,
    this.changedValues,
    this.deleteEnabled,
    this.insertEnabled,
    this.readOnly,
    this.updateEnabled,
    required String name,
  }) : super(name: name);

  DalDataProviderChangedResponse.fromJson({required Map<String, dynamic> pJson})
      : dataProvider = pJson[ApiObjectProperty.dataProvider],
        reload = pJson[ApiObjectProperty.reload],
        columnNames = pJson[ApiObjectProperty.columnNames],
        selectedRow = pJson[ApiObjectProperty.selectedRow],
        changedColumnNames = pJson[ApiObjectProperty.changedColumnNames].cast<String>(),
        changedValues = pJson[ApiObjectProperty.changedValues],
        deleteEnabled = pJson[ApiObjectProperty.deleteEnabled],
        insertEnabled = pJson[ApiObjectProperty.deleteEnabled],
        readOnly = pJson[ApiObjectProperty.readOnly],
        updateEnabled = pJson[ApiObjectProperty.updateEnabled],
        super.fromJson(pJson);
}
