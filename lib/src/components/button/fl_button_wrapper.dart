import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../mixin/ui_service_mixin.dart';
import '../../model/command/api/button_pressed_command.dart';
import '../../model/command/layout/preferred_size_command.dart';
import '../../model/component/button/fl_button_model.dart';
import '../../model/layout/layout_data.dart';
import 'fl_button_widget.dart';

class FlButtonWrapper extends StatefulWidget {
  const FlButtonWrapper({Key? key, required this.model}) : super(key: key);

  final FlButtonModel model;

  @override
  _FlButtonWrapperState createState() => _FlButtonWrapperState();
}

class _FlButtonWrapperState extends State<FlButtonWrapper> with UiServiceMixin {
  late FlButtonModel buttonModel;
  late LayoutData layoutData;

  bool sentPrefSize = false;

  @override
  void initState() {
    buttonModel = widget.model;
    uiService.registerAsLiveComponent(
        id: buttonModel.id,
        callback: ({newModel, position}) {
          if (position != null) {
            setState(() {
              layoutData.layoutPosition = position;
            });
          }

          if (newModel != null) {
            setState(() {
              buttonModel = newModel as FlButtonModel;
              sentPrefSize = false;

              layoutData = LayoutData(
                  constraints: buttonModel.constraints,
                  id: buttonModel.id,
                  preferredSize: buttonModel.preferredSize,
                  minSize: buttonModel.minimumSize,
                  maxSize: buttonModel.maximumSize,
                  parentId: buttonModel.parent);
            });
          }
        });

    layoutData = LayoutData(
        constraints: buttonModel.constraints,
        id: buttonModel.id,
        preferredSize: buttonModel.preferredSize,
        minSize: buttonModel.minimumSize,
        maxSize: buttonModel.maximumSize,
        parentId: buttonModel.parent);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final FlButtonWidget buttonWidget = FlButtonWidget(
      buttonModel: buttonModel,
      onPress: buttonPressed,
      width: _getWidthForComponent(),
      height: _getHeightForComponent(),
    );
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      postFrameCallback(timeStamp, context);
    });

    return Positioned(
      top: _getTopForPositioned(),
      left: _getLeftForPositioned(),
      width: _getWidthForPositioned(),
      height: _getHeightForPositioned(),
      child: buttonWidget,
    );
  }

  double? _getWidthForPositioned() {
    if (layoutData.hasPosition) {
      return layoutData.layoutPosition!.width;
    }
  }

  double? _getHeightForPositioned() {
    if (layoutData.hasPosition) {
      return layoutData.layoutPosition!.height;
    }
  }

  double? _getWidthForComponent() {
    if (layoutData.hasPreferredSize) {
      return layoutData.preferredSize!.width;
    } else if (layoutData.hasCalculatedSize) {
      if (layoutData.calculatedSize!.height == double.infinity) {
        return layoutData.calculatedSize!.width;
      } else if (layoutData.calculatedSize!.width == double.infinity) {
        return null;
      } else if (layoutData.hasPosition && layoutData.layoutPosition!.isComponentSize) {
        return layoutData.layoutPosition!.width;
      }
    }

    return null;
  }

  double? _getHeightForComponent() {
    if (layoutData.hasPreferredSize) {
      return layoutData.preferredSize!.height;
    } else if (layoutData.hasCalculatedSize) {
      if (layoutData.calculatedSize!.width == double.infinity) {
        return layoutData.calculatedSize!.height;
      } else if (layoutData.calculatedSize!.height == double.infinity) {
        return null;
      } else if (layoutData.hasPosition && layoutData.layoutPosition!.isComponentSize) {
        return layoutData.layoutPosition!.height;
      }
    }

    return null;
  }

  double _getTopForPositioned() {
    return layoutData.hasPosition ? layoutData.layoutPosition!.top : 0.0;
  }

  double _getLeftForPositioned() {
    return layoutData.hasPosition ? layoutData.layoutPosition!.left : 0.0;
  }

  bool isNewCalcSize() {
    return _getHeightForComponent() == null || _getWidthForComponent() == null;
  }

  void postFrameCallback(Duration time, BuildContext context) {
    Size potentialNewCalcSize = Size(context.size!.width.ceilToDouble(), context.size!.height.ceilToDouble());

    bool rebuild = false;
    bool sendCommand = !sentPrefSize;

    if (isNewCalcSize()) {
      layoutData.calculatedSize = potentialNewCalcSize;
    }

    if (layoutData.hasNewCalculatedSize) {
      sendCommand = true;
    } else {
      rebuild = true;
    }

    if (sendCommand) {
      PreferredSizeCommand preferredSizeCommand = PreferredSizeCommand(
          parentId: buttonModel.parent ?? "",
          layoutData: layoutData,
          componentId: buttonModel.id,
          reason: "Component has been rendered");

      uiService.sendCommand(preferredSizeCommand);
      sentPrefSize = true;
    }

    if (rebuild) {
      setState(() {});
    }
  }

  void buttonPressed() {
    uiService.sendCommand(ButtonPressedCommand(componentId: buttonModel.name, reason: "Button has been pressed"));
  }
}
