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

typedef SplashBuilder = Widget Function(
  BuildContext context,
  AsyncSnapshot? snapshot,
);

class Splash extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final SplashBuilder splashBuilder;
  final AsyncSnapshot? snapshot;
  final VoidCallback? onReturn;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const Splash({
    super.key,
    required this.splashBuilder,
    this.snapshot,
    this.onReturn,
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
      widget.onReturn?.call();
      return widget.onReturn != null;
    } else {
      // Still connecting, ignore back presses while connecting.
      return true;
    }
  }

  @override
  void dispose() {
    backButtonDispatcher.removeCallback(_onBackPress);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.splashBuilder.call(context, widget.snapshot);
  }
}
