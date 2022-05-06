import '../../data/column_definition.dart';
import 'ui_command.dart';

class UpdateSelectedDataCommand extends UiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Id of component that requested selected data
  final String componentId;

  /// Data of the column in the selected row
  final dynamic data;

  /// Link to the dataBook
  final String dataProvider;

  /// The columnName of the return data
  final String columnName;

  /// The columnDefinition of the requested Column
  final ColumnDefinition columnDefinition;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  UpdateSelectedDataCommand({
    required this.dataProvider,
    required String reason,
    required this.componentId,
    required this.data,
    required this.columnName,
    required this.columnDefinition,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  // TODO: implement logString
  String get logString => throw UnimplementedError();
}
