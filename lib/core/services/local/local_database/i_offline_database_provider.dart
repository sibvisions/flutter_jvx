import 'package:flutter/cupertino.dart';

import '../../../models/api/request.dart';
import '../../../models/api/response.dart';
import '../../../models/api/response/data/filter.dart';
import 'i_database_provider.dart';

abstract class IOfflineDatabaseProvider extends IDatabaseProvider {
  int syncProgress;
  Stream<Response> request(Request request);
  Future<bool> syncOnline(BuildContext context);
  Future<bool> syncDelete(
      BuildContext context, String dataProvider, Filter filter);
  Future<bool> syncInsert(
      BuildContext context, String dataProvider, List<dynamic> row);
  Future<bool> syncUpdate(
      BuildContext context, String dataProvider, List<dynamic> row);
}
