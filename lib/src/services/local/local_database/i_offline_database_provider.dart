import 'package:flutter/cupertino.dart';

import '../../../models/api/request.dart';
import '../../remote/cubit/api_cubit.dart';
import 'i_database_provider.dart';

abstract class IOfflineDatabaseProvider extends IDatabaseProvider {
  double? progress;
  Future<ApiState> request(Request? request);
  Future<bool> syncOnline(BuildContext context);
}
