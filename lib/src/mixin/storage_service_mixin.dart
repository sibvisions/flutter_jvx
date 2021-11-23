import 'package:flutter_client/src/service/service.dart';
import 'package:flutter_client/src/service/storage/i_storage_service.dart';

mixin StorageServiceMixin {
  final IStorageService storageService = services<IStorageService>();
}