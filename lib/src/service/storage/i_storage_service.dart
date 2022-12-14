/* Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import '../../model/command/base_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/panel/fl_panel_model.dart';
import '../../model/menu/menu_model.dart';
import '../../util/misc/jvx_notifier.dart';
import '../api/shared/fl_component_classname.dart';
import '../service.dart';

/// Defines the base construct of a [IStorageService],
/// Storage service is used to store & retrieve all Data of [FlComponentModel] & [MenuModel]
abstract class IStorageService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  factory IStorageService() => services<IStorageService>();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Basically resets the service
  void clear(bool pFullClear);

  /// Updates [FlComponentModel]
  /// Returns [BaseCommand] to update UI with all effected components.
  List<BaseCommand> saveComponents(
    List<dynamic>? componentsToUpdate,
    List<FlComponentModel>? newComponents,
    String screenName,
  );

  /// Deletes Screen Model, and all descendants.
  void deleteScreen({
    required String screenName,
  });

  /// Returns List of all [FlComponentModel] below it.
  List<FlComponentModel> getAllComponentsBelow({
    required FlComponentModel pParentModel,
    bool pIgnoreVisibility = false,
    bool pIncludeRemoved = false,
    bool pRecursively = true,
  });

  /// Returns List of all [FlComponentModel] below it.
  List<FlComponentModel> getAllComponentsBelowById({
    required String pParentId,
    bool pIgnoreVisibility = false,
    bool pIncludeRemoved = false,
    bool pRecursively = true,
    bool pIncludeItself = false,
  });

  /// Returns List of all [FlComponentModel] below it.
  List<FlComponentModel> getAllComponentsBelowByName({
    required String name,
    bool pIgnoreVisibility = false,
    bool pIncludeRemoved = false,
    bool pRecursively = true,
    bool pIncludeItself = false,
  });

  /// Returns component model with matching id
  FlComponentModel? getComponentModel({required String pComponentId});

  /// Returns component model with matching name
  FlComponentModel? getComponentByName({required String pComponentName});

  /// Returns panel model with matching screenClassName
  FlPanelModel? getComponentByScreenClassName({required String pScreenClassName});

  /// Returns component model with name matching [FlContainerClassname.DESKTOP_PANEL].
  JVxNotifier<FlComponentModel?> getDesktopPanelNotifier();
}
