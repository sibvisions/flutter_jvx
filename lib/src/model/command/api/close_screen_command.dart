import 'package:flutter_client/src/model/command/api/api_command.dart';

class CloseScreenCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String screenName;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  CloseScreenCommand({
    required this.screenName,
    required String reason,
  }) : super(reason: reason);

  @override
  String get logString => "CloseScreenCommand: screenName: $screenName, reason: $reason";
}
