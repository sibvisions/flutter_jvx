import '../../request/api_set_value_request.dart';
import 'api_command.dart';

/// Command to set off remote request [ApiSetValueRequest] from components
class SetValueCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the component from which the value is set
  final String componentName;

  /// Value to be set
  final dynamic value;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SetValueCommand({
    required this.componentName,
    required this.value,
    required String reason,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString => "SetValueCommand: componentName: $componentName, value: $value,   reason: $reason";
}
