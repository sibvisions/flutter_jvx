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

class ArcClipper extends CustomClipper<Path> {
  final bool reverse;

  const ArcClipper([this.reverse = false]);

  @override
  Path getClip(Size size) {
    var path = Path();

    double curveStartPointXCoord = reverse ? 30 : size.height - 30;
    double curveEndPointXCoord = reverse ? 0 : size.height;

    var startPoint = Offset(0, curveStartPointXCoord);
    var firstQuadrant = Offset(size.width / 4, curveEndPointXCoord);
    var middlePoint = Offset(size.width / 2, curveEndPointXCoord);
    var secondQuadrant = Offset(size.width - (size.width / 4), curveEndPointXCoord);
    var endPoint = Offset(size.width, curveStartPointXCoord);

    if (!reverse) {
      path.lineTo(startPoint.dx, startPoint.dy);
      path.quadraticBezierTo(firstQuadrant.dx, firstQuadrant.dy, middlePoint.dx, middlePoint.dy);
      path.quadraticBezierTo(secondQuadrant.dx, secondQuadrant.dy, endPoint.dx, endPoint.dy);
      path.lineTo(size.width, 0.0);
    } else {
      path.lineTo(0.0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(endPoint.dx, endPoint.dy);
      path.quadraticBezierTo(secondQuadrant.dx, secondQuadrant.dy, middlePoint.dx, middlePoint.dy);
      path.quadraticBezierTo(firstQuadrant.dx, firstQuadrant.dy, startPoint.dx, startPoint.dy);
      path.lineTo(0.0, 0.0);
    }

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
