import 'package:flutter_client/src/model/command/storage/storage_command.dart';
import 'package:flutter_client/src/service/storage/i_storage_service.dart';

/// Command used to tell [IStorageService] to update contained components.
// Author: Michael Schober
class UpdateComponentCommand extends StorageCommand {

  ///Json of components to be updated
  final List<dynamic> changedComponents;

  UpdateComponentCommand({
    required this.changedComponents,
    required String reason,
  }) : super(reason: reason);
}