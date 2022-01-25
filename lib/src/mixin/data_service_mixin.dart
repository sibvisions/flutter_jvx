import 'package:flutter_client/src/service/data/i_data_service.dart';
import 'package:flutter_client/src/service/service.dart';

///
/// Provides an [IDataService] instance from get.it service
///
mixin DataServiceMixin {
  final IDataService dataService = services<IDataService>();
}