import 'dart:developer';

import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/service/storage/shared/component_store.dart';

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
  Future<List<BaseCommand>> updateComponents(List? componentsToUpdate, List<FlComponentModel>? newComponents) {
    return componentStore.updateComponents(componentsToUpdate, newComponents);
  }

}