import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../model/component/icon/fl_icon_model.dart';
import '../../model/layout/layout_data.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_icon_widget.dart';

class FlIconWrapper extends BaseCompWrapperWidget<FlIconModel> {
  FlIconWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  _FlIconWrapperState createState() => _FlIconWrapperState();
}

class _FlIconWrapperState extends BaseCompWrapperState<FlIconModel> {
  @override
  Widget build(BuildContext context) {
    final FlIconWidget widget = FlIconWidget(model: model);

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: widget);
  }

  @override
  void sendCalcSize({required LayoutData pLayoutData, required String pReason}) {
    LayoutData layoutData = pLayoutData.clone();
    layoutData.calculatedSize = model.originalSize;

    layoutData.widthConstrains.forEach((key, value) {
      layoutData.widthConstrains[key] = model.originalSize.height;
    });
    layoutData.heightConstrains.forEach((key, value) {
      layoutData.heightConstrains[key] = model.originalSize.width;
    });

    super.sendCalcSize(pLayoutData: layoutData, pReason: pReason);
  }
}
