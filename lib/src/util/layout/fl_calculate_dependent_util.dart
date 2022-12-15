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

import '../../model/layout/form_layout/form_layout_anchor.dart';

class FLCalculateDependentUtil {
  /// Calculates the preferred size of relative anchors.
  static void calculateRelativeAnchor(
      {required FormLayoutAnchor leftTopAnchor,
      required FormLayoutAnchor rightBottomAnchor,
      required double preferredSize}) {
    if (leftTopAnchor.relative) {
      FormLayoutAnchor? rightBottom = rightBottomAnchor.getRelativeAnchor();
      if (rightBottom != leftTopAnchor) {
        double pref = rightBottom.getAbsolutePosition() - rightBottomAnchor.getAbsolutePosition() + preferredSize;
        double size = 0;
        if (rightBottom.relatedAnchor != null && leftTopAnchor.relatedAnchor != null) {
          size = rightBottom.relatedAnchor!.getAbsolutePosition() - leftTopAnchor.relatedAnchor!.getAbsolutePosition();
        }
        double pos = pref - size;

        if (pos < 0) {
          pos /= 2;
        } else {
          pos -= pos / 2;
        }

        if (rightBottom.firstCalculation || pos > rightBottom.position) {
          rightBottom.firstCalculation = false;
          rightBottom.position = pos;
        }
        pos = pref - size - pos;
        if (leftTopAnchor.firstCalculation || pos > leftTopAnchor.position) {
          leftTopAnchor.firstCalculation = false;
          leftTopAnchor.position = -pos;
        }
      }
    }
  }
}
