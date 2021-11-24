import '../../../../model/api/response/application_meta_data_response.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/config/client_id_command.dart';
import '../i_processor.dart';


class ApplicationMetaDataProcessor implements IProcessor {


  @override
  List<BaseCommand> processResponse(json) {
    List<BaseCommand> commands = [];
    ApplicationMetaDataResponse metaDataResponse = ApplicationMetaDataResponse.fromJson(json);

    String? clientId = metaDataResponse.clientId;
    if(clientId != null){
      ClientIdCommand idCommand = ClientIdCommand(
        reason: "Client was set in an [ApplicationMetaDataResponse]",
        clientId: clientId
      );
      commands.add(idCommand);
    }

    return commands;
  }

}