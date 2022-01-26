import 'package:flutter_client/src/model/command/data/data_command.dart';

/// Command to get data of a specific column of the selectedRow of an dataBook(dataProvider)
class GetSelectedDataCommand extends DataCommand {

  /// Link(name) to the dataBook
  final String dataProvider;

  /// Name of the column
  final String columnName;

  /// Id of the component requesting data
  final String componentId;


  GetSelectedDataCommand({
    required String reason,
    required this.componentId,
    required this.dataProvider,
    required this.columnName
  }) : super(reason: reason);



  @override
  // TODO: implement logString
  String get logString => " IMPLEMENT GET_DATA LOG";
}