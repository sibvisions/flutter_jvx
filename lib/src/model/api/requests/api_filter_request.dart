import '../api_object_property.dart';
import 'api_filter_model.dart';
import 'i_api_request.dart';

class ApiFilterRequest implements IApiRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Session id
  final String clientId;

  final String value;

  final String editorComponentId;

  final ApiFilterModel? filterCondition;

  final List<String>? columnNames;

  final String dataProvider;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiFilterRequest({
    required this.clientId,
    required this.columnNames,
    required this.value,
    required this.editorComponentId,
    required this.filterCondition,
    required this.dataProvider,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ApiObjectProperty.clientId: clientId,
        ApiObjectProperty.columnNames: columnNames,
        ApiObjectProperty.value: value,
        ApiObjectProperty.filterCondition: filterCondition?.toJson(),
        ApiObjectProperty.editorComponentId: editorComponentId,
        ApiObjectProperty.dataProvider: dataProvider,
      };
}
