import '../../request/filter.dart';
import 'api_command.dart';

class SelectRecordCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Index of selectedRecord
  final int selectedRecord;

  /// Data provider to change the selected row of
  final String dataProvider;

  final Filter? filter;

  final bool reload;

  final bool fetch;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SelectRecordCommand({
    required this.dataProvider,
    required this.selectedRecord,
    this.reload = false,
    this.fetch = false,
    this.filter,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "SelectRecordCommand{selectedRecord: $selectedRecord, dataProvider: $dataProvider, filter: $filter, reload: $reload, fetch: $fetch, ${super.toString()}}";
  }
}
