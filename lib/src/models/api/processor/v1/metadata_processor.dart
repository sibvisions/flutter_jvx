import 'package:flutter_jvx/src/models/api/action/meta_action.dart';
import 'package:flutter_jvx/src/models/api/action/processor_action.dart';
import 'package:flutter_jvx/src/models/api/i_processor.dart';
import 'package:flutter_jvx/src/models/api/responses/response_application_meta_data.dart';


class MetaDataProcessor implements IProcessor {


  @override
  List<ProcessorAction> processResponse(dynamic response) {
    List<ProcessorAction> actions = [];

    ResponseApplicationMetaData metaData = ResponseApplicationMetaData.fromJson(response);
    MetaAction metaAction = MetaAction(clientId: metaData.clientId);

    actions.add(metaAction);
    return actions;
  }

}