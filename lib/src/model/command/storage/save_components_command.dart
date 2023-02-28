/* 
 * Copyright 2022 SIB Visions GmbH
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

import '../../../service/api/shared/api_object_property.dart';
import '../../component/fl_component_model.dart';
import '../../model_factory.dart';
import 'storage_command.dart';

class SaveComponentsCommand extends StorageCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// List of [FlComponentModel] to save.
  final List<FlComponentModel>? componentsToSave;

  /// List of maps representing the changes done to a component.
  final List<dynamic>? updatedComponent;

  /// If it is the desktop panel.
  bool isDesktopPanel = false;

  /// Whether or not it only updates content or openes it as new content.
  bool isContent = false;

  /// If this save is an update. If not, will route to the workscreen or open a new content.
  bool isUpdate = false;

  /// Id of Screen to Update
  String screenName;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  SaveComponentsCommand({
    required List<dynamic>? components,
    this.screenName = "",
    this.isDesktopPanel = false,
    this.isContent = false,
    required this.isUpdate,
    required super.reason,
  })  : componentsToSave = ModelFactory.retrieveNewComponents(components),
        updatedComponent = ModelFactory.retrieveChangedComponents(components);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    String? updateCompIds = updatedComponent?.whereType<Map>().map((e) => e[ApiObjectProperty.id]).join(";");
    return "SaveComponentsCommand{componentsToSave: $componentsToSave, updatedComponent: $updateCompIds, screenName: $screenName, ${super.toString()}}";
  }
}
