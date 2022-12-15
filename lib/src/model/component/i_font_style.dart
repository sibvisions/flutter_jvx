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

abstract class IFontStyle {
  /// The plain style constant.
  static const int TEXT_PLAIN = 0;

  /// The bold style constant.  This can be combined with the other style
  /// constants (except PLAIN) for mixed styles.
  static const int TEXT_BOLD = 1;

  /// The italicized style constant.  This can be combined with the other
  /// style constants (except PLAIN) for mixed styles.
  static const int TEXT_ITALIC = 2;
}
