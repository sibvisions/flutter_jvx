import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../mixin/ui_service_mixin.dart';
import '../../model/command/layout/preferred_size_command.dart';
import '../../model/component/dummy/fl_dummy_model.dart';
import '../../model/layout/layout_data.dart';
import 'dummy_widget.dart';

class DummyWrapper extends StatefulWidget {
  const DummyWrapper({Key? key, required this.dummyModel}) : super(key: key);

  final FlDummyModel dummyModel;

  @override
  _DummyWrapperState createState() => _DummyWrapperState();
}

class _DummyWrapperState extends State<DummyWrapper> with UiServiceMixin {
  late LayoutData layoutData;
  late FlDummyModel dummyModel;
  bool sentPrefSize = false;

  @override
  void initState() {
    dummyModel = widget.dummyModel;

    uiService.registerAsLiveComponent(
        id: dummyModel.id,
        callback: ({newModel, data}) {
          if (data != null) {
            setState(() {
              layoutData = data;
            });
          }

          if (newModel != null) {
            setState(() {
              dummyModel = newModel as FlDummyModel;
              sentPrefSize = false;

              layoutData = LayoutData(
                  constraints: dummyModel.constraints,
                  id: dummyModel.id,
                  preferredSize: dummyModel.preferredSize,
                  minSize: dummyModel.minimumSize,
                  maxSize: dummyModel.maximumSize,
                  parentId: dummyModel.parent,
                  layoutPosition: layoutData.layoutPosition
              );
            });
          }
        });

    layoutData = LayoutData(
        constraints: dummyModel.constraints,
        id: dummyModel.id,
        preferredSize: dummyModel.preferredSize,
        minSize: dummyModel.minimumSize,
        maxSize: dummyModel.maximumSize,
        parentId: dummyModel.parent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const DummyWidget dummyWidget = DummyWidget();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      postFrameCallback(timeStamp, context);
    });

    return Positioned(
      top: _getTopForPositioned(),
      left: _getLeftForPositioned(),
      width: _getWidthForPositioned(),
      height: _getHeightForPositioned(),
      child: dummyWidget,
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
    if (layoutData.hasPosition && layoutData.layoutPosition!.isComponentSize) {
      return layoutData.layoutPosition!.width;
    } else if (layoutData.hasPreferredSize) {
      return layoutData.preferredSize!.width;
    } else if (layoutData.hasCalculatedSize) {
      return layoutData.calculatedSize!.width;
    }
  }

  double? _getHeightForComponent() {
    if (layoutData.hasPosition && layoutData.layoutPosition!.isComponentSize) {
      return layoutData.layoutPosition!.height;
    } else if (layoutData.hasPreferredSize) {
      return layoutData.preferredSize!.height;
    } else if (layoutData.hasCalculatedSize) {
      return layoutData.calculatedSize!.height;
    }
  }

  double _getTopForPositioned() {
    return layoutData.hasPosition ? layoutData.layoutPosition!.top : 0.0;
  }

  double _getLeftForPositioned() {
    return layoutData.hasPosition ? layoutData.layoutPosition!.left : 0.0;
  }

  void postFrameCallback(Duration time, BuildContext context) {
    if (!layoutData.hasCalculatedSize) {
      var width = context.size!.width.ceilToDouble();
      var height = context.size!.height.ceilToDouble();
      layoutData.calculatedSize = Size(width, height);
    }

    PreferredSizeCommand preferredSizeCommand = PreferredSizeCommand(
        parentId: dummyModel.parent ?? "",
        layoutData: layoutData,
        componentId: dummyModel.id,
        reason: "Component has been rendered");
    if (!sentPrefSize) {
      uiService.sendCommand(preferredSizeCommand);
    }
    sentPrefSize = true;
  }
}
