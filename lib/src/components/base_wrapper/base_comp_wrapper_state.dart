import 'dart:math';

import 'package:flutter/material.dart';

import '../../../util/logging/flutter_logger.dart';
import '../../mixin/config_service_mixin.dart';
import '../../mixin/ui_service_mixin.dart';
import '../../model/command/layout/preferred_size_command.dart';
import '../../model/component/component_subscription.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/layout/layout_data.dart';
import '../../model/layout/layout_position.dart';
import 'base_comp_wrapper_widget.dart';

/// Base state class for all component_wrappers, houses following functionality:
/// Model and layout init
/// Subscription handling in UiService
/// Getters for componentSize
abstract class BaseCompWrapperState<T extends FlComponentModel> extends State<BaseCompWrapperWidget>
    with ConfigServiceGetterMixin, UiServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  BuildContext? lastContext;

  /// [FlComponentModel] of the component, will be set in [initState]
  late T model;

  /// Layout data of the component, will be set in [initState]
  late LayoutData layoutData;

  /// 'True' if the calc size has been sent.
  bool sentCalcSize = false;

  /// The position to calculate width constraints.
  LayoutPosition? calcPosition;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();
    // Models need to be same type, dart doesn't see that both extend [FlComponentModel]
    model = getUiService().getComponentModel(pComponentId: widget.id)! as T;

    // Initialize [LayoutData] with data from [model]
    layoutData = LayoutData(
        id: model.id,
        parentId: model.parent,
        constraints: model.constraints,
        preferredSize: model.preferredSize,
        minSize: model.minimumSize,
        maxSize: model.maximumSize,
        needsRelayout: model.isVisible,
        indexOf: model.indexOf,
        heightConstrains: {},
        widthConstrains: {});

    ComponentSubscription componentSubscription = ComponentSubscription(
      compId: model.id,
      subbedObj: this,
      callback: ({data, newModel}) {
        if (!mounted) {
          return;
        }

        if (data != null) {
          receiveNewLayoutData(newLayoutData: data);
        }

        if (newModel != null) {
          receiveNewModel(newModel: newModel as T);
        }

        if (newModel == null && data == null) {
          affected();
        }
      },
    );
    getUiService().registerAsLiveComponent(pComponentSubscription: componentSubscription);
  }

  @override
  void dispose() {
    getUiService().disposeSubscriptions(pSubscriber: this);
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void affected() {}

  /// Returns Positioned Widget according to [layoutData]
  Positioned getPositioned({required Widget child}) {
    return Positioned(
      top: getTopForPositioned(),
      left: getLeftForPositioned(),
      width: getWidthForPositioned(),
      height: getHeightForPositioned(),
      child: Opacity(opacity: getConfigService().getOpacityControls(), child: child),
    );
  }

  /// Sets State with new Model
  void receiveNewModel({required T newModel}) {
    LOGGER.logD(pType: LOG_TYPE.LAYOUT, pMessage: "${newModel.id} received new Model");

    setState(() {
      // Set potentially new layout data contained in the new model
      layoutData.constraints = newModel.constraints;
      layoutData.preferredSize = newModel.preferredSize;
      layoutData.minSize = newModel.minimumSize;
      layoutData.maxSize = newModel.maximumSize;
      layoutData.parentId = newModel.parent;
      layoutData.needsRelayout = newModel.isVisible;
      layoutData.indexOf = newModel.indexOf;
      layoutData.lastCalculatedSize = layoutData.calculatedSize;
      layoutData.widthConstrains = {};
      layoutData.heightConstrains = {};
      calcPosition = null;

      model = newModel;

      // new model may have changed the calc size.
      sentCalcSize = false;
    });
  }

  /// Sets State with new LayoutData
  void receiveNewLayoutData({required LayoutData newLayoutData, bool pSetState = true}) {
    if (newLayoutData.hasPosition && newLayoutData.layoutPosition!.isConstraintCalc) {
      calcPosition = newLayoutData.layoutPosition;
      newLayoutData.layoutPosition = layoutData.layoutPosition;
      layoutData = newLayoutData;
    } else {
      layoutData = newLayoutData;
      calcPosition = null;
    }
    LOGGER.logD(pType: LOG_TYPE.LAYOUT, pMessage: "${layoutData.id} NEW DATA; ${newLayoutData.layoutPosition}");

    // Check if new position constrains component. Only sends command if constraint is new.
    if (!layoutData.isParent && (layoutData.isNewlyConstraint || calcPosition != null) && lastContext != null) {
      double calcWidth = layoutData.calculatedSize!.width;
      double calcHeight = layoutData.calculatedSize!.height;

      LayoutPosition constraintPos = calcPosition ?? layoutData.layoutPosition!;

      double positionWidth = constraintPos.width;
      double positionHeight = constraintPos.height;

      // Constraint by width
      if (layoutData.widthConstrains[positionWidth] == null && calcWidth > positionWidth) {
        double newHeight = (lastContext!.findRenderObject() as RenderBox)
            .getMaxIntrinsicHeight(max(0.0, positionWidth))
            .ceilToDouble();

        layoutData.widthConstrains[positionWidth] = newHeight;
      }

      // Constraint by height
      if (layoutData.heightConstrains[positionHeight] == null && calcHeight > positionHeight) {
        double? newWidth = (lastContext!.findRenderObject() as RenderBox)
            .getMaxIntrinsicWidth(max(0.0, positionHeight))
            .ceilToDouble();

        layoutData.heightConstrains[positionHeight] = newWidth;
      }

      var sentData = LayoutData.from(layoutData);
      sentData.layoutPosition = constraintPos;

      sendCalcSize(pLayoutData: sentData, pReason: "Component has been constrained");
    }

    if (pSetState) {
      setState(() {});
    }
  }

  /// Callback called after every build
  void postFrameCallback(BuildContext context) {
    lastContext = context;

    if (!sentCalcSize) {
      if (!layoutData.hasPreferredSize) {
        layoutData.calculatedSize = calculateSize(context);
      } else {
        layoutData.calculatedSize = layoutData.preferredSize;
      }

      sendCalcSize(pLayoutData: layoutData.clone(), pReason: "Component has been rendered");
      sentCalcSize = true;
    }
  }

  /// Calculates the size of the component
  Size calculateSize(BuildContext context) {
    double minWidth = (context.findRenderObject() as RenderBox).getMaxIntrinsicWidth(double.infinity).ceilToDouble();
    double minHeight = (context.findRenderObject() as RenderBox).getMaxIntrinsicHeight(double.infinity).ceilToDouble();
    return Size(minWidth, minHeight);
  }

  /// Sends the calc size.
  void sendCalcSize({required LayoutData pLayoutData, required String pReason}) {
    PreferredSizeCommand preferredSizeCommand = PreferredSizeCommand(layoutData: pLayoutData, reason: pReason);

    getUiService().sendCommand(preferredSizeCommand);
  }

  double getTopForPositioned() {
    return layoutData.hasPosition ? layoutData.layoutPosition!.top : 0.0;
  }

  double getLeftForPositioned() {
    return layoutData.hasPosition ? layoutData.layoutPosition!.left : 0.0;
  }

  double getWidthForPositioned() {
    return layoutData.hasPosition ? layoutData.layoutPosition!.width : 0.0;
  }

  double getHeightForPositioned() {
    return layoutData.hasPosition ? layoutData.layoutPosition!.height : 0.0;
  }
}
