import 'storage_command.dart';

class DeleteScreenCommand extends StorageCommand {
  final String screenName;

  final bool beamBack;

  DeleteScreenCommand({
    required this.screenName,
    this.beamBack = true,
    required super.reason,
  });

  @override
  String toString() {
    return 'DeleteScreenCommand{screenName: $screenName, beamBack: $beamBack, ${super.toString()}}';
  }
}
