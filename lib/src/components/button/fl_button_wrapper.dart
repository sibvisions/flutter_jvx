import 'dart:developer';

import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/model/layout/layout_data.dart';

import '../../mixin/ui_service_mixin.dart';

import 'fl_button_widget.dart';
import '../../model/component/button/fl_button_model.dart';
import 'package:flutter/material.dart';

class FlButtonWrapper extends StatefulWidget {
  const FlButtonWrapper({Key? key, required this.model}) : super(key: key);

  final FlButtonModel model;

  @override
  _FlButtonWrapperState createState() => _FlButtonWrapperState();
}

class _FlButtonWrapperState extends State<FlButtonWrapper> with UiServiceMixin {
  late LayoutData layoutData;

  @override
  void initState() {
    uiService.registerAsLiveComponent(widget.model.id, () {
      log("oi there");
    });
    layoutData = LayoutData(
        id: widget.model.id,
        preferredSize: widget.model.preferredSize,
        minSize: widget.model.minimumSize,
        maxSize: widget.model.maximumSize);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance!.addPostFrameCallback(postFrameCallback);
    final FlButtonWidget buttonWidget = FlButtonWidget(
      buttonModel: widget.model,
      width: _getWidthForComponent(),
      heigth: _getHeigthForComponent(),
    );

    return Positioned(
      width: _getWidthForPositioned(),
      height: _getHeigthForPositioned(),
      child: buttonWidget,
    );
  }

  double? _getWidthForPositioned() {
    if (layoutData.hasPosition && !layoutData.layoutPosition!.isComponentSize) {
      return layoutData.layoutPosition!.width;
    } else {
      return null;
    }
  }

  double? _getHeigthForPositioned() {
    if (layoutData.hasPosition && !layoutData.layoutPosition!.isComponentSize) {
      return layoutData.layoutPosition!.height;
    } else {
      return null;
    }
  }

  double? _getWidthForComponent() {
    if (layoutData.hasPosition && layoutData.layoutPosition!.isComponentSize) {
      return layoutData.layoutPosition!.width;
    } else {
      return null;
    }
  }

  double? _getHeigthForComponent() {
    if (layoutData.hasPosition && layoutData.layoutPosition!.isComponentSize) {
      return layoutData.layoutPosition!.height;
    } else {
      return null;
    }
  }

  void postFrameCallback(Duration time) {}
}
