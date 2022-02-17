import 'package:flutter_client/src/model/command/api/api_command.dart';

class SetValuesCommand extends ApiCommand {
  /// Id of component
  final String componentId;

  /// DataRow or DataProvider of the component
  final String dataProvider;

  /// List of columns, order of which corresponds to order of values list
  final List<String> columnNames;

  /// List of values, order of which corresponds to order of columnsName list
  final List<dynamic> values;

  SetValuesCommand(
      {required this.componentId,
      required this.dataProvider,
      required this.columnNames,
      required this.values,
      required String reason})
      : super(reason: reason);

  @override
  // TODO: implement logString
  String get logString => throw UnimplementedError();
}
