import 'package:flutter_client/src/model/api/requests/api_filter_model.dart';
import 'package:flutter_client/src/model/command/api/api_command.dart';

class SelectRecordCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Index of selectedRecord
  final int selectedRecord;

  /// Data provider to change the selected row of
  final String dataProvider;

  final ApiFilterModel? filter;

  final bool reload;

  final bool fetch;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SelectRecordCommand({
    required String reason,
    required this.dataProvider,
    required this.selectedRecord,
    this.reload = false,
    this.fetch = false,
    this.filter,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString =>
      "SelectRecordCommand: dataProvider: $dataProvider, slectedRecord: $selectedRecord, reload: $reload, fetch: $fetch, filter: $filter,  reason: $reason";
}
