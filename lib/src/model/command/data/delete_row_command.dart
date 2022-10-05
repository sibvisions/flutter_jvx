import 'data_command.dart';

class DeleteRowCommand extends DataCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Data provider
  final String dataProvider;

  /// Index of deleted row
  final int deletedRow;

  /// Index of newly selected row
  final int newSelectedRow;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DeleteRowCommand({
    required this.dataProvider,
    required this.deletedRow,
    required this.newSelectedRow,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "DeleteRowCommand{dataProvider: $dataProvider, deletedRow: $deletedRow, newSelectedRow: $newSelectedRow, ${super.toString()}}";
  }
}
