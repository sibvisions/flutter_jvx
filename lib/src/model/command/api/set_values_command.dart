import 'package:flutter_client/src/model/api/requests/api_filter_model.dart';
import 'package:flutter_client/src/model/api/requests/api_set_values_request.dart';

import 'api_command.dart';

/// Command to set off remote request [ApiSetValuesRequest]
class SetValuesCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Id of component
  final String componentId;

  /// DataRow or DataProvider of the component
  final String dataProvider;

  /// List of columns, order of which corresponds to order of values list
  final List<String> columnNames;

  /// List of values, order of which corresponds to order of columnsName list
  final List<dynamic> values;

  /// Filter of this setValues, used in table to edit non selected rows.
  final ApiFilterModel? filter;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SetValuesCommand({
    required this.componentId,
    required this.dataProvider,
    required this.columnNames,
    required this.values,
    required String reason,
    this.filter,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString =>
      "SetValuesCommand: componentId: $componentId, dataProvider: $dataProvider, columnNames: $columnNames, values: $values, reason: $reason";
}
