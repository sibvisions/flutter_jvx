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

import '../../util/jvx_colors.dart';

class LoadingBar extends InheritedWidget {
  final bool show;

  const LoadingBar({
    super.key,
    required this.show,
    required super.child,
  });

  /// The closest instance of this class that encloses the given context.
  static LoadingBar of(BuildContext context) {
    final LoadingBar? result = maybeOf(context);
    assert(result != null, "No LoadingBar found in context");
    return result!;
  }

  /// The closest instance of this class that encloses the given context.
  ///
  /// If no instance of this class encloses the given context, will return null.
  /// To throw an exception instead, use [of] instead of this function.
  static LoadingBar? maybeOf(BuildContext? context) {
    return context?.dependOnInheritedWidgetOfExactType<LoadingBar>();
  }

  @override
  bool updateShouldNotify(covariant LoadingBar oldWidget) => show != oldWidget.show;

  static Widget wrapLoadingBar(Widget child) {
    return Builder(builder: (context) {
      return Stack(children: [
        child,
        if (LoadingBar.maybeOf(context)?.show ?? false)
          LinearProgressIndicator(
            minHeight: 5,
            color: JVxColors.toggleColor(Theme.of(context).colorScheme.primary),
            backgroundColor: Colors.transparent,
          ),
      ]);
    });
  }
}
