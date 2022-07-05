import 'package:flutter_client/src/model/command/api/api_command.dart';

class FetchCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final List<String>? columnNames;

  final bool? includeMetaData;

  final int fromRow;

  final int rowCount;

  final String dataProvider;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FetchCommand({
    required String reason,
    required this.fromRow,
    required this.rowCount,
    required this.dataProvider,
    this.includeMetaData,
    this.columnNames,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString =>
      "FetchCommand: fromRow: $fromRow, rowCount: $rowCount, dataProvider: $dataProvider, includeMetaData: $includeMetaData, columnNames: $columnNames, reason: $reason";
}
