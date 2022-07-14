import '../service/service.dart';
import '../service/storage/i_storage_service.dart';

mixin StorageServiceMixin {
  final IStorageService storageService = services<IStorageService>();
}

mixin StorageServiceGetterMixin {
  IStorageService getStorageService() {
    return services<IStorageService>();
  }
}
