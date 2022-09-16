import '../src/service/service.dart';
import '../src/service/storage/i_storage_service.dart';

export '../src/service/storage/i_storage_service.dart';
export '../src/service/storage/impl/default/storage_service.dart';

///
///  Provides an [IStorageService] instance from get.it service
///
mixin StorageServiceGetterMixin {
  IStorageService getStorageService() {
    return services<IStorageService>();
  }
}
