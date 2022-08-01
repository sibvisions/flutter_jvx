import '../src/service/service.dart';
import '../src/service/storage/i_storage_service.dart';

mixin StorageServiceGetterMixin {
  IStorageService getStorageService() {
    return services<IStorageService>();
  }
}
