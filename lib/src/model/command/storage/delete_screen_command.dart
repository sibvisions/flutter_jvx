import 'storage_command.dart';

class DeleteScreenCommand extends StorageCommand {
  final String screenName;

  final bool beamBack;

  DeleteScreenCommand({
    required this.screenName,
    required String reason,
    this.beamBack = true,
  }) : super(reason: reason);

  @override
  String get logString => "DeleteScreenCommand: screenName: $screenName, reason: $reason";
}
