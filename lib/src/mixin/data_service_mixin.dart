import '../service/data/i_data_service.dart';
import '../service/service.dart';

///
/// Provides an [IDataService] instance from get.it service
///
mixin DataServiceMixin {
  final IDataService dataService = services<IDataService>();
}

mixin DataServiceGetterMixin {
  IDataService getDataService() {
    return services<IDataService>();
  }
}
