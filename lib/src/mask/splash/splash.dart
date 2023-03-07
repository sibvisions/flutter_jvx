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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../flutter_ui.dart';
import '../../util/image/image_loader.dart';
import 'jvx_splash.dart';

typedef SplashBuilder = Widget Function(
  BuildContext context,
  AsyncSnapshot? snapshot,
);

class Splash extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final SplashBuilder? splashBuilder;
  final AsyncSnapshot? snapshot;
  final VoidCallback? returnToApps;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const Splash({
    super.key,
    this.splashBuilder,
    this.snapshot,
    required this.returnToApps,
  });

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  late final RootBackButtonDispatcher backButtonDispatcher;

  @override
  void initState() {
    super.initState();
    backButtonDispatcher = RootBackButtonDispatcher();
    backButtonDispatcher.addCallback(_onBackPress);
  }

  /// Returns true if this callback will handle the request;
  /// otherwise, returns false.
  Future<bool> _onBackPress() async {
    if ([null, ConnectionState.none, ConnectionState.done].contains(widget.snapshot?.connectionState)) {
      widget.returnToApps?.call();
    }
    // We always handle it.
    return true;
  }

  @override
  void dispose() {
    backButtonDispatcher.removeCallback(_onBackPress);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.splashBuilder?.call(context, widget.snapshot) ??
        JVxSplash(
          snapshot: widget.snapshot,
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
