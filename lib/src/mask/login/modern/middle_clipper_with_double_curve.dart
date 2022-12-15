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

import 'package:flutter/cupertino.dart';

/// Creates a path like this
///
/// ```
/// x
/// x
/// x
/// xx
///  xxxx
///     xxxxxxxxxxxxxxxxxxxxxxxxxx
///                              x
///                              x
///           This is the        x
///              inside          x
///                              x
///                              x
///     xxxxxxxxxxxxxxxxxxxxxxxxxx
///  xxxx
/// xx
/// x
/// x
/// x
/// ```
class MiddleClipperWithDoubleCurve extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 75.0;
    double topInset = size.height / 3;
    double bottomInset = 150.0;
    double additionalRadius = 20.0;

    return Path()
      ..lineTo(0.0, topInset - radius)
      ..quadraticBezierTo(0.0, topInset, radius + additionalRadius, topInset)
      ..lineTo(size.width, topInset)
      ..lineTo(size.width, size.height - bottomInset)
      ..lineTo(0.0 + radius + additionalRadius, size.height - bottomInset)
      ..quadraticBezierTo(0.0, size.height - bottomInset, 0.0, size.height - bottomInset + radius)
      ..lineTo(0.0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
