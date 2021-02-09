import 'package:flutter/cupertino.dart';

import '../../../models/api/request.dart';
import '../../../models/api/response.dart';
import 'i_database_provider.dart';

abstract class IOfflineDatabaseProvider extends IDatabaseProvider {
  double progress;
  Stream<Response> request(Request request);
  Future<bool> syncOnline(BuildContext context);
}
