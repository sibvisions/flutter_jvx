import 'package:flutter/material.dart';
import 'package:flutter_client/util/parse_util.dart';

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
      widgetsSelectedOnce.add(initialIndex);
    }
  }

  @override
  void animateTo(int value, {Duration duration = kTabScrollDuration, Curve curve = Curves.ease}) {
    if (isTabEnabled(value)) {
      widgetsSelectedOnce.add(value);
      changedIndexTo(value);
      super.animateTo(value, duration: duration, curve: curve);
    } else {
      changedIndexTo(-1);
    }
  }

  void animateInternally(int value, {Duration duration = kTabScrollDuration, Curve curve = Curves.ease}) {
    if (isTabEnabled(value)) {
      widgetsSelectedOnce.add(value);
      super.animateTo(value, duration: duration, curve: curve);
    }
  }

  bool isTabEnabled(int value) {
    return (ParseUtil.parseBoolFromString(tabs[value].model.constraints!.split(';').first) ?? false);
  }
}
