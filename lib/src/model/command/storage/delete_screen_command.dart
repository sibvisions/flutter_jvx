import 'package:flutter_client/src/model/command/storage/storage_command.dart';

class DeleteScreenCommand extends StorageCommand{
  final String screenName;

  DeleteScreenCommand({
    required this.screenName,
    required String reason
  }): super(reason: reason);

  @override
  // TODO: implement logString
  String get logString => throw UnimplementedError();
}