import '../src/service/data/i_data_service.dart';
import '../src/service/service.dart';

export '../src/service/data/i_data_service.dart';
export '../src/service/data/impl/data_service.dart';

///
/// Provides an [IDataService] instance from get.it service
///
mixin DataServiceGetterMixin {
  IDataService getDataService() {
    return services<IDataService>();
  }
}
