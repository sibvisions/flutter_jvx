import '../../../../model/command/base_command.dart';
import '../../../../model/component/fl_component_model.dart';
import '../../i_storage_service.dart';
import '../../shared/component_store.dart';

/// Manages all component data received from remote server
class DefaultStorageService implements IStorageService {
  final StorageService storageService = StorageService();

  @override
  Future<List<FlComponentModel>> getScreenByScreenClassName(String screenClassName) {
    return storageService.getScreenByScreenClassName(screenClassName);
  }

  @override
  Future<List<BaseCommand>> updateComponents(List? componentsToUpdate, List<FlComponentModel>? newComponents, String screenName) {
    return storageService.updateComponents(componentsToUpdate, newComponents, screenName);
  }

  @override
  Future<void> deleteScreen({required String screenName}) {
    return storageService.deleteScreen(screenName: screenName);
  }
}
