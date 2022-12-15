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

import '../command/base_command.dart';
import '../layout/layout_data.dart';
import 'fl_component_model.dart';

class ComponentSubscription<T extends FlComponentModel> {
  /// The object that subscribed, used for deletion
  final Object subbedObj;

  /// Component id, will receive all changes to this component
  final String compId;

  /// Component callback to notify a component it is affected.
  final Function()? affectedCallback;

  /// Component callback to receive new model data.
  final Function()? modelCallback;

  /// Component callback to receive new layout data
  final Function(LayoutData pLayout)? layoutCallback;

  /// Component callback to notify of saving.
  final BaseCommand? Function()? saveCallback;

  ComponentSubscription({
    required this.compId,
    required this.subbedObj,
    this.affectedCallback,
    this.modelCallback,
    this.layoutCallback,
    this.saveCallback,
  });
}
