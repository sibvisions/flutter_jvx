import 'api_command.dart';

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
    required this.fromRow,
    required this.rowCount,
    required this.dataProvider,
    this.includeMetaData,
    this.columnNames,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "FetchCommand{columnNames: $columnNames, includeMetaData: $includeMetaData, fromRow: $fromRow, rowCount: $rowCount, dataProvider: $dataProvider, ${super.toString()}}";
  }
}
