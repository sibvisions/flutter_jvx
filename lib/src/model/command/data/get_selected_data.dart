import 'package:flutter_client/src/model/command/data/data_command.dart';

class GetSelectedDataCommand extends DataCommand {

  /// Link(name) to the dataBook
  final String dataProvider;

  /// Name of the column
  final String columnName;


  GetSelectedDataCommand({
    required String reason,
    required this.dataProvider,
    required this.columnName
  }) : super(reason: reason);



  @override
  // TODO: implement logString
  String get logString => " IMPLEMENT GET_DATA LOG";
}