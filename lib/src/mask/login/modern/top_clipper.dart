/* Copyright 2022 SIB Visions GmbH
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
/// x         This is the
/// x            inside
/// xx
///  xxxx
///     xxxxxxxxxxxxxxxxxxxxxxxxxx
///
///        Rest of the screen
/// ```
class TopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 75.0;
    double height = size.height / 3;

    return Path()
      ..lineTo(0.0, height - radius)
      ..quadraticBezierTo(0.0, height, radius, height)
      ..lineTo(size.width, height)
      ..lineTo(size.width, 0.0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
