import '../../service/api/shared/api_object_property.dart';
import '../data/filter_condition.dart';
import 'filter.dart';
import 'i_session_request.dart';

class ApiFilterRequest extends ISessionRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String? value;

  final String editorComponentId;

  final Filter? filter;

  final FilterCondition? filterCondition;

  final List<String>? columnNames;

  final String dataProvider;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiFilterRequest({
    required this.editorComponentId,
    required this.dataProvider,
    this.columnNames,
    this.value,
    this.filter,
    this.filterCondition,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.columnNames: columnNames,
        ApiObjectProperty.value: value,
        ApiObjectProperty.filter: filter?.toJson(),
        ApiObjectProperty.filterCondition: filterCondition?.toJson(),
        ApiObjectProperty.editorComponentId: editorComponentId,
        ApiObjectProperty.dataProvider: dataProvider,
      };
}
