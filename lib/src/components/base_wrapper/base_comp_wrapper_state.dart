import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/base_wrapper/base_comp_wrapper_widget.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/command/layout/preferred_size_command.dart';
import 'package:flutter_client/src/model/component/fl_component_model.dart';
import 'package:flutter_client/src/model/layout/layout_data.dart';

/// Base state class for all component_wrappers, houses following functionality:
/// Model and layout init
/// Subscription handling in UiService
/// Getters for componentSize
abstract class BaseCompWrapperState<T extends FlComponentModel> extends State<BaseCompWrapperWidget> with UiServiceMixin {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// [FlComponentModel] of the component, will be set in [initState]
  late T model;
  /// Layout data of the component, will be set in [initState]
  late LayoutData layoutData;
  /// 'True' if the calc size has been sent.
  bool sentCalcSize = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();
    // Models need to be same type, dart doesn't see that both extend [FlComponentModel]
    model = widget.model as T;
    // Initialize [LayoutData] with data from [model]
    layoutData = LayoutData(
        id: model.id,
        parentId: model.parent,
        constraints: model.constraints,
        preferredSize: model.preferredSize,
        minSize: model.minimumSize,
        maxSize: model.maximumSize,
    );

    uiService.registerAsLiveComponent(id: model.id, callback: ({data, newModel}) {
      if(data != null){
        receiveNewLayoutData(newLayoutData: data);
      }

      if(newModel != null){
        receiveNewModel(newModel: newModel as T);
      }
    });
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns Positioned Widget according to [layoutData]
  Positioned getPositioned({required Widget child}){

    return Positioned(
      top: getTopForPositioned(),
      left: getLeftForPositioned(),
      width: getWidthForPositioned(),
      height: getHeightForPositioned(),
      child: child,
    );
  }

  /// Sets State with new Model
  receiveNewModel({required T newModel}){
    setState(() {
      // Set potentially new layout data contained in the new model
      layoutData.constraints = newModel.constraints;
      layoutData.preferredSize = newModel.preferredSize;
      layoutData.minSize = newModel.minimumSize;
      layoutData.maxSize = newModel.maximumSize;
      layoutData.parentId = newModel.parent;
      layoutData.calculatedSize = null;

      model = newModel;

      // new model may have changed the calc size.
      sentCalcSize = false;
    });
  }

  /// Sets State with new LayoutData
  receiveNewLayoutData({required LayoutData newLayoutData}){
    if (layoutData.layoutPosition == null || layoutData.layoutPosition!.timeOfCall!.isBefore(newLayoutData.layoutPosition!.timeOfCall!))
    {
      setState(() {
        log("${model.id} is receiving position of ${newLayoutData.layoutPosition}");
        layoutData.layoutPosition = newLayoutData.layoutPosition;
      });
    }
  }

  /// Callback called after every build
  void postFrameCallback(Duration time, BuildContext context) {
    // Size potentialNewCalcSize = Size(context.size!.width.ceilToDouble(), context.size!.height.ceilToDouble());

    double? minWidth;
    double? minHeight;
    if (getWidthForComponent() == null)
    {
      minWidth = (context.findRenderObject() as RenderBox).getMaxIntrinsicWidth(getHeightForComponent() ?? 10000).ceilToDouble();
    }
    if (getHeightForComponent() == null)
    {
      minHeight = (context.findRenderObject() as RenderBox).getMaxIntrinsicHeight(getWidthForComponent() ?? 10000).ceilToDouble();
    }

    bool rebuild = false;

    if (isNewCalcSize()) {
      layoutData.calculatedSize = Size(minWidth ?? layoutData.calculatedSize!.width, minHeight ?? layoutData.calculatedSize!.height);
      if (layoutData.hasNewCalculatedSize) {
        sentCalcSize = false;
      } else {
        rebuild = true;
      }
    }

    if (!sentCalcSize) {
      PreferredSizeCommand preferredSizeCommand = PreferredSizeCommand(
          parentId: model.parent ?? "",
          layoutData: layoutData.clone(),
          componentId: model.id,
          reason: "Component has been rendered");

      uiService.sendCommand(preferredSizeCommand);
      sentCalcSize = true;
    }

    if (rebuild) {
      setState(() {});
    }
  }

  double? getWidthForComponent() {
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

  double? getHeightForComponent() {
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

  double getTopForPositioned() {
    return layoutData.hasPosition ? layoutData.layoutPosition!.top : 0.0;
  }

  double getLeftForPositioned() {
    return layoutData.hasPosition ? layoutData.layoutPosition!.left : 0.0;
  }

  double? getWidthForPositioned() {
    return layoutData.hasPosition ? layoutData.layoutPosition!.width : 0.0;
  }

  double? getHeightForPositioned() {
    return layoutData.hasPosition ? layoutData.layoutPosition!.height : 0.0;
  }

  bool isNewCalcSize() {
    return getHeightForComponent() == null || getWidthForComponent() == null;
  }
}