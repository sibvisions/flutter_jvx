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

import 'dart:ui';

import '../model/layout/layout_data.dart';
import '../model/layout/layout_position.dart';
import 'i_layout.dart';

class TabLayout implements ILayout {
  // int selectedIndex;

  double tabHeaderHeight;

  TabLayout({required this.tabHeaderHeight}); //, required this.selectedIndex});

  @override
  void calculateLayout(LayoutData pParent, List<LayoutData> pChildren) {
    LayoutPosition? childrenPosition;
    if (pParent.hasPosition) {
      double width = pParent.layoutPosition!.width;
      double height = pParent.layoutPosition!.height - tabHeaderHeight;
      childrenPosition = LayoutPosition(width: width, height: height, top: 0, left: 0, isComponentSize: true);
    }

    double calcWidth = 0.0;
    double calcHeight = 0.0;
    for (LayoutData childData in pChildren) {
      if (childData.hasCalculatedSize) {
        if (childData.calculatedSize!.width > calcWidth) {
          calcWidth = childData.calculatedSize!.width;
        }
        if (childData.calculatedSize!.height > calcHeight) {
          calcHeight = childData.calculatedSize!.height;
        }
      }

      childData.layoutPosition = childrenPosition;
    }

    pParent.calculatedSize = Size(calcWidth, calcHeight + tabHeaderHeight);
  }

  @override
  ILayout clone() {
    return TabLayout(tabHeaderHeight: tabHeaderHeight); //, selectedIndex: selectedIndex);
  }
}
