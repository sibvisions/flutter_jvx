import 'package:flutter/material.dart';

import '../../base_wrapper/base_comp_wrapper_widget.dart';

class FlTabController extends TabController {
  Set<int> widgetsSelectedOnce = {};

  List<BaseCompWrapperWidget> tabs;

  Function(int pValue) changedIndexTo;

  FlTabController({
    int initialIndex = 0,
    required this.tabs,
    required TickerProvider vsync,
    required this.changedIndexTo,
  }) : super(
          initialIndex: initialIndex,
          length: tabs.length,
          vsync: vsync,
        ) {
    if (initialIndex >= 0 && initialIndex < tabs.length) {
      widgetsSelectedOnce.add(tabs[initialIndex].model.indexOf);
    }
  }

  @override
  void animateTo(int value, {Duration duration = kTabScrollDuration, Curve curve = Curves.ease}) {
    if (tabs[value].model.isEnabled) {
      widgetsSelectedOnce.add(tabs[value].model.indexOf);
      changedIndexTo(tabs[value].model.indexOf);
      super.animateTo(value, duration: duration, curve: curve);
    }
  }
}
