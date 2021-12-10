import 'dart:developer';

import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/model/command/api/button_pressed_command.dart';
import 'package:flutter_client/src/model/command/layout/preferred_size_command.dart';
import 'package:flutter_client/src/model/layout/layout_data.dart';
import 'package:flutter_client/src/model/layout/layout_position.dart';
import 'package:flutter_client/src/service/service.dart';
import 'package:flutter_client/src/service/ui/impl/ui_service.dart';

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

  bool sentPrefSize = false;

  @override
  void initState() {
    uiService.registerAsLiveComponent(widget.model.id, (FlButtonModel? btnModel, LayoutPosition? position) {

      if(position != null){
        setState(() {
          layoutData.layoutPosition = position;
        });
      }
    });
    layoutData = LayoutData(
        constraints: widget.model.constraints,
        id: widget.model.id,
        preferredSize: widget.model.preferredSize,
        minSize: widget.model.minimumSize,
        maxSize: widget.model.maximumSize);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {postFrameCallback(timeStamp, context);});
    final FlButtonWidget buttonWidget = FlButtonWidget(
      buttonModel: widget.model,
      onPress: buttonPressed,
      width: _getWidthForComponent(),
      heigth: _getHeightForComponent(),
    );

    return Positioned(
      top: _getTopForPositioned(),
      left: _getLeftForPositioned(),
      width: _getWidthForPositioned(),
      height: _getHeightForPositioned(),
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

  double? _getHeightForPositioned() {
    if (layoutData.hasPosition && !layoutData.layoutPosition!.isComponentSize) {
      return layoutData.layoutPosition!.height;
    } else {
      return null;
    }
  }

  double? _getWidthForComponent() {
    if (layoutData.hasPosition && layoutData.layoutPosition!.isComponentSize) {
      return layoutData.layoutPosition!.width;
    } else if (layoutData.hasPreferredSize) {
      return layoutData.preferredSize!.width;
    } else if (layoutData.hasCalculatedSize) {
      return layoutData.calculatedSize!.width;
    } else {
      return null;
    }
  }

  double? _getHeightForComponent() {
    if (layoutData.hasPosition && layoutData.layoutPosition!.isComponentSize) {
      return layoutData.layoutPosition!.height;
    } else if (layoutData.hasPreferredSize) {
      return layoutData.preferredSize!.height;
    } else if (layoutData.hasCalculatedSize) {
      return layoutData.calculatedSize!.height;
    } else {
      return null;
    }
  }

  double _getTopForPositioned() {
    return layoutData.hasPosition ? layoutData.layoutPosition!.top : 0.0;
  }

  double _getLeftForPositioned() {
    return layoutData.hasPosition ? layoutData.layoutPosition!.left : 0.0;
  }

  void postFrameCallback(Duration time, BuildContext context) {
    layoutData.calculatedSize = context.size;

    PreferredSizeCommand preferredSizeCommand = PreferredSizeCommand(
        parentId: widget.model.parent ?? "",
        layoutData: layoutData,
        componentId: widget.model.id,
        reason: "Component has been rendered"
    );
    if(!sentPrefSize){
      uiService.sendCommand(preferredSizeCommand);
    }
    sentPrefSize = true;
  }

  void buttonPressed()
  {
    uiService.sendCommand(ButtonPressedCommand(componentId: widget.model.id, reason: "Button has been pressed"));
  }
}
