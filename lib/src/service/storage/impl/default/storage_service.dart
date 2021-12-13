import '../../../../model/command/base_command.dart';
import '../../shared/component_store.dart';

import '../../../../model/component/fl_component_model.dart';
import '../../../../model/menu/menu_model.dart';
import '../../i_storage_service.dart';

/// Contains all component & menu Data
// Author: Michael Schober
class DefaultStorageService implements IStorageService {
  final ComponentStore componentStore = ComponentStore();

  @override
  Future<MenuModel> getMenu() {
    return componentStore.getMenu();
  }

  @override
  Future<List<FlComponentModel>> getScreenByScreenClassName(String screenClassName) {
    return componentStore.getScreenByScreenClassName(screenClassName);
  }

  @override
  Future<bool> saveMenu(MenuModel menuModel) {
    return componentStore.saveMenu(menuModel);
  }

  @override
  Future<List<BaseCommand>> updateComponents(
      List? componentsToUpdate, List<FlComponentModel>? newComponents, String screenName) {
    return componentStore.updateComponents(componentsToUpdate, newComponents, screenName);
  }

  @override
  Future<void> deleteScreen({required String screenName}) {
    return componentStore.deleteScreen(screenName: screenName);
  }
}
