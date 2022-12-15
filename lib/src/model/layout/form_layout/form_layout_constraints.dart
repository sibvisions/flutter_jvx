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

import 'form_layout_anchor.dart';

/// The Constraint stores the top, left, bottom and right Anchor for layouting a component
class FormLayoutConstraints {
  /// The top anchor
  final FormLayoutAnchor topAnchor;

  /// The left anchor
  final FormLayoutAnchor leftAnchor;

  /// The bottom anchor
  final FormLayoutAnchor bottomAnchor;

  /// The right anchor
  final FormLayoutAnchor rightAnchor;

  FormLayoutConstraints(
      {required this.bottomAnchor, required this.leftAnchor, required this.rightAnchor, required this.topAnchor});
}
