import 'api_command.dart';

class PressButtonCommand extends ApiCommand {
  final String componentId;

  PressButtonCommand({required this.componentId, required String reason}) : super(reason: reason);

  @override
  // TODO: implement logString
  String get logString => throw UnimplementedError();
}
