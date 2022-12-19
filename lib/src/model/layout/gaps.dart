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

import '../../layout/i_layout.dart';

class Gaps {
  /// The vertical gap of a layout
  int verticalGap;

  /// The horizontal gap of a layout
  int horizontalGap;

  Gaps({required this.horizontalGap, required this.verticalGap});

  /// Returns Gaps instance, if provided List is null the gaps will be set to 0.
  static Gaps createFromList({required List<String>? gapsList}) {
    Gaps gaps;
    if (gapsList == null) {
      gaps = Gaps(horizontalGap: 0, verticalGap: 0);
    } else {
      gaps = Gaps(
          horizontalGap: (int.parse(gapsList[0]) * ILayout.LAYOUT_MULTIPLIER).ceil(),
          verticalGap: (int.parse(gapsList[1]) * ILayout.LAYOUT_MULTIPLIER).ceil());
    }
    return gaps;
  }
}
