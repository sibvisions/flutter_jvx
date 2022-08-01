import '../api_object_property.dart';
import 'filter.dart';
import 'i_api_request.dart';

class ApiFilterRequest implements IApiRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Session id
  final String clientId;

  final String? value;

  final String editorComponentId;

  final Filter? filter;

  final List<String>? columnNames;

  final String dataProvider;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiFilterRequest({
    required this.clientId,
    required this.editorComponentId,
    required this.dataProvider,
    this.columnNames,
    this.value,
    this.filter,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ApiObjectProperty.clientId: clientId,
        ApiObjectProperty.columnNames: columnNames,
        ApiObjectProperty.value: value,
        ApiObjectProperty.filter: filter?.toJson(),
        ApiObjectProperty.editorComponentId: editorComponentId,
        ApiObjectProperty.dataProvider: dataProvider,
      };
}
