import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/download_images_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class DownloadResourcesProcessor with ApiServiceMixin implements ICommandProcessor<DownloadImagesCommand> {

  @override
  Future<List<BaseCommand>> processCommand(DownloadImagesCommand command) async {



    return [];
  }

}