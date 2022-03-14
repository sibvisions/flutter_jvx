import 'package:flutter_client/src/model/command/api/api_command.dart';

class TabCloseCommand extends ApiCommand {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the tabset panel
  final String componentName;

  /// Index of the closed tab
  final int index;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  TabCloseCommand({
    required this.componentName,
    required this.index,
    required String reason,
  }) : super(reason: reason);

  @override
  // TODO: implement logString
  String get logString => throw UnimplementedError();

}