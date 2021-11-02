import 'package:flutter_jvx/src/models/api/i_processor.dart';
import 'package:flutter_jvx/src/models/events/meta/client_id_changed_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/on_client_id_event.dart';
import 'package:flutter_jvx/src/util/mixin/service/config_app_service_mixin.dart';

import '../../responses.dart';

class MetaDataProcessor with OnClientIdEvent, ConfigAppServiceMixin implements IProcessor {


  @override
  void processResponse(dynamic response) {
    ResponseApplicationMetaData metaData = ResponseApplicationMetaData.fromJson(response);
    configAppService.clientId = metaData.clientId;
    var event = ClientIdEvent(
        clientId: metaData.clientId,
        origin: this,
        reason: "ClientId was set by Server ApplicationMetaData Response"
    );
    fireClientIdEvent(event);
  }

}