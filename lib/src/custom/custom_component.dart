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

import 'package:flutter/widgets.dart';

import '../model/component/fl_component_model.dart';

/// Used to replace specific components in a screen
class CustomComponent {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the component
  final String componentName;

  /// The minimum size of the component. If not set, uses the one provided by the model of the original component.
  final Size? minSize;

  /// The maximum size of the component. If not set, uses the one provided by the model of the original component.
  final Size? maxSize;

  /// The preferred size of the component. If not set, uses the one provided by the model of the original component.
  ///
  /// This is the size that is used in the layout.
  /// If not set, the component will be asked for its intrinsic height.
  /// Therefore the uppermost widget in the custom component should either support having its intrinsic height asked,
  /// or set this property.
  /// For example, a LayoutBuilder can not be asked for its intrinsic height, therefore this property must be set.
  final Size? preferredSize;

  /// Component that will replace the server sent component with matching name
  final Widget Function(BuildContext context, FlComponentModel model) componentBuilder;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  CustomComponent({
    required this.componentName,
    required this.componentBuilder,
    this.minSize,
    this.maxSize,
    this.preferredSize,
  });
}
