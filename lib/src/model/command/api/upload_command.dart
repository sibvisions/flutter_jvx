import 'package:universal_io/io.dart';

import '../../../../services.dart';
import 'api_command.dart';

class UploadCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The id of the file for the server.
  String fileId;

  /// The file to send.
  File file;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  UploadCommand({
    required this.fileId,
    required this.file,
    required super.reason,
  }) {
    callback = () => IUiService().getAppManager()?.onSuccessfulStartup();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return 'UploadCommand{fileId: $fileId, file: $file, reason: $reason}';
  }
}
