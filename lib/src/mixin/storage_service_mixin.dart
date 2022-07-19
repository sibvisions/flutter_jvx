import '../service/service.dart';
import '../service/storage/i_storage_service.dart';

mixin StorageServiceGetterMixin {
  IStorageService getStorageService() {
    return services<IStorageService>();
  }
}
