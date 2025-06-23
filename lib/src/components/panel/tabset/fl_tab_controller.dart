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

import '../../../util/parse_util.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';

class FlTabController extends TabController {
  /// The last tab controller used. Saved for old values / call to dispose.
  List<FlTabController> lastControllers = [];

  Set<int> widgetsSelectedOnce = {};

  List<BaseCompWrapperWidget> tabs;

  Function(int pValue) changedIndexTo;

  FlTabController(
      {int initialIndex = 0,
      required this.tabs,
      required super.vsync,
      required this.changedIndexTo,
      FlTabController? lastController})
      : super(
          initialIndex: initialIndex,
          length: tabs.length,
        ) {
    if (initialIndex >= 0 && initialIndex < tabs.length) {
      widgetsSelectedOnce.add(initialIndex);
    }
    if (lastController != null) {
      lastControllers.add(lastController);
      lastControllers.addAll(lastController.lastControllers);
      lastController.lastControllers.clear();
      widgetsSelectedOnce.addAll(lastController.widgetsSelectedOnce);

      if (lastControllers.length > 10) {
        FlTabController removedController = lastControllers.removeLast();
        removedController.dispose();
      }
    }
  }

  bool get isAllowedToAnimate {
    return _isAllowedToAnimate(this) &&
        lastControllers.every((FlTabController controller) => _isAllowedToAnimate(controller));
  }

  bool _isAllowedToAnimate(FlTabController controller) {
    bool isAllowed = controller.offset == 0.0 && !controller.indexIsChanging;

    if (isAllowed && animation != null) {
      isAllowed = (controller.animation!.value - controller.animation!.value.floor()) == 0;
    }

    return isAllowed;
  }

  @override
  void animateTo(int value, {Duration? duration, Curve curve = Curves.ease, bool animate = false}) {
    duration ??= kTabScrollDuration;
    if (isTabEnabled(value) && isAllowedToAnimate) {
      widgetsSelectedOnce.add(value);
      if (!animate) {
        changedIndexTo(value);
      } else {
        super.animateTo(value, duration: duration, curve: curve);
      }
    }
  }

  // @override
  // double get offset {
  //   double currentOffset = super.offset;

  //   if (currentOffset != 0 && lastController != null) {
  //     currentOffset = lastController!.offset;
  //   }

  //   return currentOffset;
  // }

  @override
  void dispose() {
    for (FlTabController lastController in lastControllers) {
      lastController.dispose();
    }
    super.dispose();
  }

  bool isTabEnabled(int value) {
    return (ParseUtil.parseBool(tabs[value].model.constraints!.split(";").first) ?? false);
  }
}
