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

import '../model/layout/layout_data.dart';
import '../util/i_clonable.dart';
import 'border_layout.dart';
import 'flow_layout.dart';
import 'form_layout.dart';
import 'grid_layout.dart';
import 'split_layout.dart';

// The states a layout can be in. If a component is dirty, it gets redrawn.

/// Defines the base construct of a [ILayout].
/// It is generally advised to use this class as an interface and not as a superclass.
abstract class ILayout implements ICloneable {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Calculates the constraints and widths and heigths of the children components and those of the [pParent].
  void calculateLayout(LayoutData pParent, List<LayoutData> pChildren);

  @override
  ILayout clone();

  /// Returns the correct [ILayout] implementation depending on the data in [pLayout].
  ///
  /// Current implementations are:
  ///
  /// [BorderLayout] , [FormLayout], [FlowLayout], [GridLayout]
  static ILayout? getLayout(String? pLayout, String? pLayoutData, double pScaling) {
    if (pLayout != null) {
      final list = pLayout.split(",");

      switch (list.first) {
        case "BorderLayout":
          return BorderLayout(layoutString: pLayout, scaling: pScaling);
        case "FormLayout":
          return FormLayout(layoutData: pLayoutData!, layoutString: pLayout, scaling: pScaling);
        case "GridLayout":
          return GridLayout(layoutString: pLayout, scaling: pScaling);
        case "FlowLayout":
          return FlowLayout(layoutString: pLayout, scaling: pScaling);
        case "SplitLayout":
          return SplitLayout();
        default:
          return null;
      }
    }

    return null;
  }
}
