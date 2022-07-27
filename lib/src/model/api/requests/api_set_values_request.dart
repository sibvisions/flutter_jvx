import '../api_object_property.dart';
import 'filter.dart';
import 'i_api_request.dart';

/// Request to set the value of a data-bound component
class ApiSetValuesRequest extends IApiRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Id of the current session
  final String clientId;

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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiSetValuesRequest({
    required this.componentId,
    required this.clientId,
    required this.dataProvider,
    required this.columnNames,
    required this.values,
    this.filter,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ApiObjectProperty.clientId: clientId,
        ApiObjectProperty.dataProvider: dataProvider,
        ApiObjectProperty.componentId: componentId,
        ApiObjectProperty.columnNames: columnNames,
        ApiObjectProperty.values: values,
        ApiObjectProperty.filter: filter?.toJson(),
      };
}
