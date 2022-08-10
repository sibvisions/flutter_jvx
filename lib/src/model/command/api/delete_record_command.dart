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
    required String reason,
    required this.dataProvider,
    this.selectedRow,
    this.fetch = false,
    this.filter,
    this.filterCondition,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString =>
      "DeleteRecordCommand: dataProvider: $dataProvider, selectedRow: $selectedRow, fetch: $fetch, filter: $filter, filterCondition: $filterCondition, reason: $reason";
}
