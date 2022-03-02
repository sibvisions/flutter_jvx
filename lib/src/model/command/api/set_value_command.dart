import 'api_command.dart';

class SetValueCommand extends ApiCommand {
  /// Id of component
  final String componentId;

  /// Value of component
  final dynamic value;

  SetValueCommand({required this.componentId, required this.value, required String reason}) : super(reason: reason);

  @override
  // TODO: implement logString
  String get logString => throw UnimplementedError();
}
