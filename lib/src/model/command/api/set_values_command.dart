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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SetValuesCommand({
    required this.componentId,
    required this.dataProvider,
    required this.columnNames,
    required this.values,
    required String reason
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  // TODO: implement logString
  String get logString => throw UnimplementedError();
}
