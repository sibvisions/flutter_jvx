/*
 * Copyright 2023 SIB Visions GmbH
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

/// Provides a nested [Navigator] with a custom theme.
///
/// The navigator can then be used to push local dialogs without affecting the rest of the tree
/// as it doesn't affect any other possible navigators in the tree.
///
/// This uses a Navigator instead of a full blown MaterialApp to not touch existing routes, see [Navigator.reportsRouteUpdateToEngine].
/// It also connects the [NavigatorState] to the [future] object, so this can be re-used by multiple futures.
///
/// [AsyncSnapshot] from a parent [FutureBuilder] can't be used, because [Navigator.onGenerateRoute]
/// is only called once-ish, therefore we have to trigger the update from inside.
class FutureNestedNavigator extends StatelessWidget {
  final AsyncWidgetBuilder builder;
  final ThemeData theme;
  final Future future;
  final Widget? child;
  final TransitionDelegate transitionDelegate;
  final Key? navigatorKey;

  const FutureNestedNavigator({
    super.key,
    required this.builder,
    required this.theme,
    required this.future,
    this.child,
    this.transitionDelegate = const DefaultTransitionDelegate<dynamic>(),
    this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (child != null) child!,
        Theme(
          data: theme,
          child: HeroControllerScope.none(
            child: Navigator(
              key: navigatorKey,
              transitionDelegate: transitionDelegate,
              onGenerateRoute: (settings) => PageRouteBuilder(
                settings: settings,
                pageBuilder: (context, _, __) => FutureBuilder(
                  future: future,
                  builder: builder,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
