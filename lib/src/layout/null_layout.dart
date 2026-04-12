/*
 * Copyright 2026 SIB Visions GmbH
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

import 'dart:math';

import 'package:flutter/widgets.dart';

import '../model/layout/layout_data.dart';
import '../model/layout/layout_position.dart';
import '../util/i_clonable.dart';
import 'i_layout.dart';

/// The NullLayout allows free positioning.
class NullLayout extends ILayout implements ICloneable {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The modifier with which to scale the layout.
  final double scaling;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes a [NullLayout].
  NullLayout({required this.scaling});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  NullLayout clone() {
    return NullLayout(scaling: scaling);
  }

  @override
  void calculateLayout(LayoutData parent, List<LayoutData> children) {
    double width = 0;
    double height = 0;

    LayoutPosition? bounds;

    for (int i = 0; i < children.length; i++) {

      bounds = children[i].bounds;

      if (bounds != null) {
        width = max(width, bounds.left + bounds.width);
        height = max(height, bounds.top + bounds.height);

        children[i].layoutPosition = children[i].bounds;
      }
      else {
        children[i].layoutPosition = LayoutPosition(top: 0, left: 0, width: 0, height: 0);
      }
    }

    parent.calculatedSize = Size(width, height);
  }

}
