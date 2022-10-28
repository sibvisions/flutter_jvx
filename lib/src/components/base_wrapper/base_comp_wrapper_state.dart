import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../../custom/app_manager.dart';
import '../../../flutter_jvx.dart';
import '../../../services.dart';
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
abstract class BaseCompWrapperState<T extends FlComponentModel> extends State<BaseCompWrapperWidget> {
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
    model = IUiService().getComponentModel(pComponentId: widget.id)! as T;

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
      widthConstrains: {},
    );

    ComponentSubscription componentSubscription = ComponentSubscription<T>(
      compId: model.id,
      subbedObj: this,
      affectedCallback: affected,
      layoutCallback: receiveNewLayoutData,
      modelCallback: receiveNewModel,
      saveCallback: createSaveCommand,
    );
    IUiService().registerAsLiveComponent(pComponentSubscription: componentSubscription);
  }

  @override
  void dispose() {
    IUiService().disposeSubscriptions(pSubscriber: this);
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

  BaseCommand? createSaveCommand() {
    return null;
  }

  void affected() {}

  /// Returns Positioned Widget according to [layoutData]
  Positioned getPositioned({required Widget child}) {
    return Positioned(
      top: getTopForPositioned(),
      left: getLeftForPositioned(),
      width: getWidthForPositioned(),
      height: getHeightForPositioned(),
      child: Opacity(opacity: IConfigService().getOpacityControls(), child: child),
    );
  }

  /// Sets State with new Model
  void receiveNewModel(T pModel) {
    FlutterJVx.log.d("${pModel.id} received new Model");

    setState(() {
      // Set potentially new layout data contained in the new model
      layoutData.constraints = pModel.constraints;
      layoutData.preferredSize = pModel.preferredSize;
      layoutData.minSize = pModel.minimumSize;
      layoutData.maxSize = pModel.maximumSize;
      layoutData.parentId = pModel.parent;
      layoutData.needsRelayout = pModel.isVisible;
      layoutData.indexOf = pModel.indexOf;
      layoutData.lastCalculatedSize = layoutData.calculatedSize;
      layoutData.widthConstrains = {};
      layoutData.heightConstrains = {};
      calcPosition = null;

      model = pModel;

      // new model may have changed the calc size.
      sentCalcSize = false;
    });
  }

  /// Sets State with new LayoutData
  void receiveNewLayoutData(LayoutData pLayoutData, [bool pSetState = true]) {
    if (pLayoutData.hasPosition && pLayoutData.layoutPosition!.isConstraintCalc) {
      calcPosition = pLayoutData.layoutPosition;
      pLayoutData.layoutPosition = layoutData.layoutPosition;
      layoutData = pLayoutData;
    } else {
      layoutData = pLayoutData;
      calcPosition = null;
    }
    FlutterJVx.log.d("${layoutData.id} NEW DATA; ${pLayoutData.layoutPosition}");

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
    if (!mounted) {
      return;
    }

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

    IUiService().sendCommand(preferredSizeCommand);
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
