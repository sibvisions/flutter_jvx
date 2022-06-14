import 'package:flutter_client/src/model/command/api/download_images_command.dart';
import 'package:flutter_client/src/model/command/api/download_translation_command.dart';

import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/config/save_app_meta_data_command.dart';
import '../../i_command_processor.dart';

class SaveAppMetaDataProcessor with ConfigServiceMixin implements ICommandProcessor<SaveAppMetaDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveAppMetaDataCommand command) async {
    // Remove '.' to allow easy saving of images in filesystem
    String version = command.metaData.version.replaceAll(".", "_");

    configService.setClientId(command.metaData.clientId);
    configService.setVersion(version);
    // String langCode =

    bool doesExist = await configService.getFileManager().doesFileExist(pPath: "");

    if (!doesExist) {
      return [
        DownloadImagesCommand(reason: "Resources should be downloaded"),
      ];
    }
    return [DownloadTranslationCommand(reason: "Translation should be downloaded")];
  }
}
