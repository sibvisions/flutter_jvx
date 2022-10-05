import 'storage_command.dart';

class DeleteScreenCommand extends StorageCommand {
  final String screenName;
  bool beamBack = true;

  DeleteScreenCommand({
    required this.screenName,
    required super.reason,
  });

  @override
  String toString() {
    return "DeleteScreenCommand{screenName: $screenName, beamBack: $beamBack, ${super.toString()}}";
  }
}
