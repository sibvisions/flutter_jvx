import 'package:flutter/material.dart';
import 'package:flutter_client/util/parse_util.dart';

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
      required TickerProvider vsync,
      required this.changedIndexTo,
      FlTabController? lastController})
      : super(
          initialIndex: initialIndex,
          length: tabs.length,
          vsync: vsync,
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
    bool isAllowed = true;

    for (FlTabController checkTabController in lastControllers) {
      isAllowed = checkTabController.offset == 0.0 && !checkTabController.indexIsChanging;
      if (isAllowed && checkTabController.animation != null) {
        isAllowed = (checkTabController.animation!.value - checkTabController.animation!.value.floor()) == 0;
      }
    }

    return isAllowed;
  }

  @override
  void animateTo(int value,
      {Duration duration = kTabScrollDuration, Curve curve = Curves.ease, bool pInternally = false}) {
    if (isTabEnabled(value) && isAllowedToAnimate) {
      widgetsSelectedOnce.add(value);
      if (!pInternally) {
        changedIndexTo(value);
      }
      super.animateTo(value, duration: duration, curve: curve);
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
    return (ParseUtil.parseBoolFromString(tabs[value].model.constraints!.split(';').first) ?? false);
  }
}
