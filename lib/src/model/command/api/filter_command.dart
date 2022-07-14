import '../../api/requests/api_filter_model.dart';
import 'api_command.dart';

class FilterCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String editorId;

  final String value;

  final List<String>? columnNames;

  final ApiFilterModel? filterCondition;

  final String dataProvider;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FilterCommand({
    required this.editorId,
    required this.value,
    required this.dataProvider,
    this.columnNames,
    this.filterCondition,
    required String reason,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString =>
      "FilterCommand: editorId: $editorId, value: $value, dataProvider: $dataProvider, columnNames: $columnNames, filterCondition: $filterCondition, reason: $reason";
}
