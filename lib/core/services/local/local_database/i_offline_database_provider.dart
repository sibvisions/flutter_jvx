import 'package:flutter/cupertino.dart';
import 'package:jvx_flutterclient/core/utils/network/network_info.dart';

import '../../../models/api/request.dart';
import '../../../models/api/response.dart';
import 'i_database_provider.dart';

abstract class IOfflineDatabaseProvider extends IDatabaseProvider {
  Stream<Response> request(Request request);
  Future<bool> syncOnline(BuildContext context);
}
