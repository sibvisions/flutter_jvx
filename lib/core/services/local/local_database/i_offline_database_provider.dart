import 'package:flutter/cupertino.dart';

import '../../../models/api/request.dart';
import '../../../models/api/response.dart';
import 'i_database_provider.dart';

abstract class IOfflineDatabaseProvider extends IDatabaseProvider {
  int syncProgress;
  Stream<Response> request(Request request);
  Future<bool> syncOnline(BuildContext context,
      [List<String> syncDataProvider]);
  Future<bool> syncDelete(
      BuildContext context, String dataProvider, List<dynamic> row);
}
