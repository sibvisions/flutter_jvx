import 'package:flutter_client/src/model/api/response/dal_fetch_response.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/api/shared/i_processor.dart';

class DalFetchProcessor extends IProcessor {


  @override
  List<BaseCommand> processResponse(json) {

    DalFetchResponse res = DalFetchResponse.fromJson(json);

    return [];
  }

}