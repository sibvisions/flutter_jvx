import '../../service/api/shared/api_object_property.dart';
import '../data/filter_condition.dart';
import 'filter.dart';
import 'session_request.dart';

/// Request to set the value of a data-bound component
class ApiSetValuesRequest extends SessionRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// DataRow or DataProvider of the component
  final String dataProvider;

  /// Id of the component
  final String componentId;

  /// List of columns, order of which corresponds to order of [values] list
  final List<String> columnNames;

  /// List of values, order of which corresponds to order of [columnNames] list
  final List<dynamic> values;

  /// Filter of this setValues, used in table to edit non selected rows.
  final Filter? filter;

  final FilterCondition? filterCondition;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiSetValuesRequest({
    required this.componentId,
    required this.dataProvider,
    required this.columnNames,
    required this.values,
    this.filter,
    this.filterCondition,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ApiObjectProperty.dataProvider: dataProvider,
        ApiObjectProperty.componentId: componentId,
        ApiObjectProperty.columnNames: columnNames,
        ApiObjectProperty.values: values,
        ApiObjectProperty.filter: filter?.toJson(),
        ApiObjectProperty.filterCondition: filterCondition?.toJson(),
      };
}
