import 'package:flutter_client/src/mixin/api_service_mixin.dart';
import 'package:flutter_client/src/model/command/api/download_resources_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/command/shared/i_command_processor.dart';

class DownloadResourcesProcessor with ApiServiceMixin implements ICommandProcessor<DownloadResourcesCommand> {

  @override
  Future<List<BaseCommand>> processCommand(DownloadResourcesCommand command) async {



    return [];
  }

}