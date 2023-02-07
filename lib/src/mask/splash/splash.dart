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

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../flutter_ui.dart';
import '../../util/image/image_loader.dart';
import 'jvx_splash.dart';

typedef SplashBuilder = Widget Function(
  BuildContext context,
  AsyncSnapshot? snapshot,
);

class Splash extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final SplashBuilder? splashBuilder;
  final AsyncSnapshot? snapshot;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const Splash({
    super.key,
    this.splashBuilder,
    this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    return splashBuilder?.call(context, snapshot) ??
        JVxSplash(
          snapshot: snapshot,
          logo: SvgPicture.asset(
            ImageLoader.getAssetPath(
              FlutterUI.package,
              "assets/images/J.svg",
            ),
            width: 138,
            height: 145,
          ),
          background: SvgPicture.asset(
            ImageLoader.getAssetPath(
              FlutterUI.package,
              "assets/images/JVx_Bg.svg",
            ),
            fit: BoxFit.fill,
          ),
          branding: Image.asset(
            ImageLoader.getAssetPath(
              FlutterUI.package,
              "assets/images/logo.png",
            ),
            width: 200,
          ),
        );
  }
}
