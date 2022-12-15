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

      if (lastControllers.length > 3) {
        FlTabController removedController = lastControllers.removeLast();
        removedController.dispose();
      }
    }
  }

  bool get isAllowedToAnimate {
    for (FlTabController checkTabController in lastControllers) {
      bool isAllowed = checkTabController.offset == 0.0 && !checkTabController.indexIsChanging;

      if (isAllowed && checkTabController.animation != null) {
        isAllowed = (checkTabController.animation!.value - checkTabController.animation!.value.floor()) == 0;
      }

      if (!isAllowed) {
        return false;
      }
    }

    return true;
  }

  @override
  void animateTo(int value, {Duration? duration, Curve curve = Curves.ease, bool pInternally = false}) {
    duration ??= kTabScrollDuration;
    if (isTabEnabled(value) && isAllowedToAnimate) {
      widgetsSelectedOnce.add(value);
      if (!pInternally) {
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
