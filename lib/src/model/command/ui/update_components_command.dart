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

import 'ui_command.dart';

/// This command will update components cache.
class UpdateComponentsCommand extends UiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The new components
  final List<String> newComponents;

  /// List of components whose model changed
  final List<String> changedComponents;

  /// List of components to delete
  final Set<String> deletedComponents;

  /// The affected component models.
  final Set<String> affectedComponents;

  /// Whether to notify the desktop panel.
  final bool notifyDesktopPanel;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  UpdateComponentsCommand({
    this.newComponents = const [],
    this.affectedComponents = const {},
    this.changedComponents = const [],
    this.deletedComponents = const {},
    this.notifyDesktopPanel = false,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String propertiesAsString() {
    return "newComponents: $newComponents, changedComponents: $changedComponents, "
           "deletedComponents: $deletedComponents, affectedComponents: $affectedComponents, "
           "notifyDesktopPanel: $notifyDesktopPanel, ${super.propertiesAsString()}";
  }

}
