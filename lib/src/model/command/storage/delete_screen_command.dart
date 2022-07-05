import 'storage_command.dart';

class DeleteScreenCommand extends StorageCommand {
  final String screenName;

  DeleteScreenCommand({
    required this.screenName,
    required String reason,
  }) : super(reason: reason);

  @override
  String get logString => "DeleteScreenCommand: screenName: $screenName, reason: $reason";
}
