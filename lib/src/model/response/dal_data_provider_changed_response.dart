import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

class DalDataProviderChangedResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Data provider that changed
  final String dataProvider;

  /// -1 | x
  /// -1 - delete all local data and re-fetch
  /// x - re-fetch this specific row
  final int? reload;

  /// New selected row
  final int? selectedRow;

  /// The deleted row
  final int? deletedRow;

  /// Name of columns of the data book, only not null if [changedValues] is provided
  final List<String>? columnNames;

  /// Name of all changed columns, only not null if [changedValues] is provided
  final List<String>? changedColumnNames;

  /// Values of all changed Columns, corresponds to [changedColumnNames] order
  final List<dynamic>? changedValues;

  /// If data book is readOnly
  final bool? readOnly;

  /// If data book has deletion enabled
  final bool? deleteEnabled;

  /// If data book has update enabled
  final bool? updateEnabled;

  /// If data book has insert enabled
  final bool? insertEnabled;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DalDataProviderChangedResponse({
    required this.dataProvider,
    this.reload,
    this.columnNames,
    this.selectedRow,
    this.deletedRow,
    this.changedColumnNames,
    this.changedValues,
    this.deleteEnabled,
    this.insertEnabled,
    this.readOnly,
    this.updateEnabled,
    required super.name,
    required super.originalRequest,
  });

  DalDataProviderChangedResponse.fromJson(super.json, super.originalRequest)
      : dataProvider = json[ApiObjectProperty.dataProvider],
        reload = json[ApiObjectProperty.reload],
        columnNames = json[ApiObjectProperty.columnNames],
        selectedRow = json[ApiObjectProperty.selectedRow],
        deletedRow = json[ApiObjectProperty.deletedRow],
        changedColumnNames = json[ApiObjectProperty.changedColumnNames]?.cast<String>(),
        changedValues = json[ApiObjectProperty.changedValues],
        deleteEnabled = json[ApiObjectProperty.deleteEnabled],
        insertEnabled = json[ApiObjectProperty.insertEnabled],
        readOnly = json[ApiObjectProperty.readOnly],
        updateEnabled = json[ApiObjectProperty.updateEnabled],
        super.fromJson();
}
