import '../../data/filter_condition.dart';
import '../../request/filter.dart';
import 'api_command.dart';

/// This is the jvx command to delete a record.
class DeleteRecordCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Data provider to change selected row of
  final String dataProvider;

  /// Filter
  final Filter? filter;

  final FilterCondition? filterCondition;

  final int? selectedRow;

  final bool fetch;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DeleteRecordCommand({
    required this.dataProvider,
    this.selectedRow,
    this.fetch = false,
    this.filter,
    this.filterCondition,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return 'DeleteRecordCommand{dataProvider: $dataProvider, filter: $filter, filterCondition: $filterCondition, selectedRow: $selectedRow, fetch: $fetch, ${super.toString()}}';
  }
}
