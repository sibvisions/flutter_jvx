import 'dart:developer';

import 'package:flutter_client/src/model/api/response/dal_meta_data_response.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/api/shared/i_processor.dart';

class DalMetaDataProcessor implements IProcessor {

  @override
  List<BaseCommand> processResponse(json) {


    DalMetaDataResponse metaDataResponse = DalMetaDataResponse.fromJson(pJson: json);

    return [];
  }

}