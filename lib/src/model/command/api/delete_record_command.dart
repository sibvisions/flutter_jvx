import 'package:flutter_client/src/model/command/api/api_command.dart';

import '../../api/requests/api_filter_model.dart';

class DeleteRecordCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Data provider to change selected row of
  final String dataProvider;

  /// Filter
  final ApiFilterModel? filter;

  final int selectedRow;

  final bool fetch;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DeleteRecordCommand({
    required String reason,
    required this.dataProvider,
    required this.selectedRow,
    this.fetch = false,
    this.filter,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString =>
      "DeleteRecordCommand: dataProvider: $dataProvider, selectedRow: $selectedRow, fetch: $fetch, filter: $filter, reason: $reason";
}
