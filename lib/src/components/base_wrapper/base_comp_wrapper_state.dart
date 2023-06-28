/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:math';

import 'package:flutter/material.dart';

import '../../flutter_ui.dart';
import '../../model/command/base_command.dart';
import '../../model/command/layout/preferred_size_command.dart';
import '../../model/command/ui/set_focus_command.dart';
import '../../model/component/component_subscription.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/layout/layout_data.dart';
import '../../model/layout/layout_position.dart';
import '../../service/config/i_config_service.dart';
import '../../service/layout/i_layout_service.dart';
import '../../service/ui/i_ui_service.dart';
import 'base_comp_wrapper_widget.dart';
import 'base_cont_wrapper_state.dart';

/// The base class for all states of FlutterJVxs component wrapper.
///
/// A wrapper is a stateful widget that wraps FlutterJVx widgets and handles all JVx specific implementations and functionality.
/// e.g:
///
/// Model inits/updates; Layout inits/updates; Size calculation; Subscription handling for data widgets.
abstract class BaseCompWrapperState<T extends FlComponentModel> extends State<BaseCompWrapperWidget<T>> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The last context passed to the [postFrameCallback].
  ///
  /// Used for size calculations.
  BuildContext? lastContext;

  /// [FlComponentModel] of the component, will be set in [initState]
  T get model => widget.model;

  /// [LayoutData] of the component, will be set in [initState]
  late LayoutData layoutData;

  /// `true` if the layout data has been sent.
  bool sentLayoutData = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  BaseCompWrapperState();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    // Initialize [LayoutData] with data from [model]
    layoutData = LayoutData(
      id: model.id,
      name: model.name,
      parentId: model.parent,
      constraints: model.constraints,
      preferredSize: model.preferredSize,
      minSize: model.minimumSize,
      maxSize: model.maximumSize,
      indexOf: model.indexOf,
      heightConstrains: {},
      widthConstrains: {},
    );

    ComponentSubscription componentSubscription = ComponentSubscription<T>(
      compId: model.id,
      subbedObj: this,
      affectedCallback: affected,
      layoutCallback: receiveNewLayoutData,
      modelCallback: modelUpdated,
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

  /// Returns a [Positioned] widget according to [layoutData].
  ///
  /// Every wrapper itself is "wrapped" in a [Positioned] widget,
  /// which will positioned itself inside the [Stack] of a [BaseContWrapperState]'s widget.
  Positioned wrapWidget({required Widget child}) {
    return Positioned(
      top: getTopForPositioned(),
      left: getLeftForPositioned(),
      width: getWidthForPositioned(),
      height: getHeightForPositioned(),
      child: wrapWithSemantic(
        wrapWithDesignListener(
          wrapWithOpacity(
            child,
          ),
        ),
      ),
    );
  }

  Widget wrapWithOpacity(Widget pChild) {
    return ValueListenableBuilder(
      valueListenable: IConfigService().applicationStyle,
      builder: (context, value, builderChild) {
        return Opacity(
          opacity: double.parse(value?['opacity.controls'] ?? "1"),
          child: builderChild,
        );
      },
      child: pChild,
    );
  }

  Widget wrapWithSemantic(Widget pChild) {
    return Semantics(
      enabled: model.ariaLabel.isNotEmpty,
      container: true,
      explicitChildNodes: true,
      label: model.ariaLabel,
      child: pChild,
    );
  }

  Widget wrapWithDesignListener(Widget pChild) {
    return ValueListenableBuilder(
      valueListenable: IUiService().applicationParameters,
      child: pChild,
      builder: (context, applicationParameters, builderChild) {
        if (!applicationParameters.designModeAllowed) {
          return builderChild!;
        }

        return ValueListenableBuilder(
          valueListenable: IUiService().designMode,
          child: builderChild,
          builder: (context, designMode, builderChild) {
            if (!designMode) {
              return builderChild!;
            }

            return GestureDetector(
              onLongPress: () {
                if (IUiService().designModeElement.value == model.id) {
                  IUiService().updateDesignModeElement(null);
                } else {
                  IUiService().updateDesignModeElement(model.id);
                }
              },
              child: AbsorbPointer(
                absorbing: absorbPointerInDesignMode,
                child: wrapWithDesignSelection(builderChild!),
              ),
            );
          },
        );
      },
    );
  }

  /// Whether or not the component should absorb pointer events for its children while designing.
  ///
  /// Container should not absorb, while components do.
  ///
  /// Default: true
  bool get absorbPointerInDesignMode {
    return true;
  }

  Widget wrapWithDesignSelection(Widget pChild) {
    return ValueListenableBuilder(
      valueListenable: IUiService().designModeElement,
      child: pChild,
      builder: (context, designModeElement, builderChild) {
        if (designModeElement != model.id) {
          return builderChild!;
        }

        return Container(
          foregroundDecoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(0, 0),
              end: const Alignment(0.25, 0),
              // 0.25/2 = 1/8 * 2 colors = 16 lines
              stops: const [0, 0.5, 0.5, 1],
              transform: const GradientRotation(1 / 4 * pi),
              // rotate the gradient by 45 degrees
              tileMode: TileMode.repeated,
              // repeats the gradient over the canvas
              colors: [
                // Colors are easy thanks to Flutter's Colors class.
                Theme.of(context).colorScheme.primary.withOpacity(0.5),
                Theme.of(context).colorScheme.primary.withOpacity(0.5),
                Theme.of(context).colorScheme.background.withOpacity(0.5),
                Theme.of(context).colorScheme.background.withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary, //Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          child: builderChild,
        );
      },
    );
  }

  /// Callback called after every build.
  void postFrameCallback(BuildContext context) {
    if (!mounted) {
      return;
    }

    lastContext = context;

    if (!sentLayoutData) {
      if (!layoutData.hasPreferredSize) {
        layoutData.calculatedSize = calculateSize(context);
      } else {
        layoutData.calculatedSize = layoutData.preferredSize;
      }

      sendCalcSize(pLayoutData: layoutData.clone(), pReason: "Component has been rendered");
      sentLayoutData = true;
    }
  }

  /// Sets State with new Model
  void modelUpdated() {
    FlutterUI.logUI.d("${model.name}|${model.id} received new Model");

    setState(() {
      // Set potentially new layout data contained in the new model
      layoutData.constraints = model.constraints;
      layoutData.preferredSize = model.preferredSize;
      layoutData.minSize = model.minimumSize;
      layoutData.maxSize = model.maximumSize;
      layoutData.parentId = model.parent;
      layoutData.indexOf = model.indexOf;
      layoutData.lastCalculatedSize = layoutData.calculatedSize;
      layoutData.widthConstrains = {};
      layoutData.heightConstrains = {};

      // new model may have changed the calc size.
      sentLayoutData = false;
    });
  }

  /// Callback that notifiers this component that it's children have been changed.
  void affected() {
    // Components usually don't have children, therefore -> Does nothing
  }

  /// Is called when a new [LayoutData] is sent from the [ILayoutService].
  void receiveNewLayoutData(LayoutData pLayoutData) {
    LayoutPosition? calcPosition;
    if (pLayoutData.hasPosition && pLayoutData.layoutPosition!.isConstraintCalc) {
      calcPosition = pLayoutData.layoutPosition;
      pLayoutData.layoutPosition = layoutData.layoutPosition;
      layoutData = pLayoutData;
    } else {
      layoutData = pLayoutData;
      calcPosition = null;
    }

    FlutterUI.logLayout.d("${model.name}|${model.id} receiveNewLayoutData ${pLayoutData.layoutPosition}");

    // Check if new position constrains component. Only sends command if constraint is new.
    if (calcPosition != null && lastContext != null) {
      sendCalcSize(pLayoutData: calculateConstrainedSize(calcPosition), pReason: "Component has been constrained");
    }

    setState(() {});
  }

  /// Calculates the size the components wants to have if a specific side of it is constrained.
  ///
  /// E.g. Calculates how much height a [FlLabelWidget] would want, if it only had 100px space in width.
  LayoutData calculateConstrainedSize(LayoutPosition? calcPosition) {
    double calcWidth = layoutData.calculatedSize!.width;
    double calcHeight = layoutData.calculatedSize!.height;

    LayoutPosition constraintPos = calcPosition ?? layoutData.layoutPosition!;

    double positionWidth = constraintPos.width;
    double positionHeight = constraintPos.height;

    // Constraint by width
    if (layoutData.widthConstrains[positionWidth] == null && calcWidth > positionWidth) {
      double newHeight =
          (lastContext!.findRenderObject() as RenderBox).getMaxIntrinsicHeight(max(0.0, positionWidth)).ceilToDouble();

      layoutData.widthConstrains[positionWidth] = newHeight;
    }

    // Constraint by height
    if (layoutData.heightConstrains[positionHeight] == null && calcHeight > positionHeight) {
      double? newWidth =
          (lastContext!.findRenderObject() as RenderBox).getMaxIntrinsicWidth(max(0.0, positionHeight)).ceilToDouble();

      layoutData.heightConstrains[positionHeight] = newWidth;
    }

    var sentData = LayoutData.from(layoutData);
    sentData.layoutPosition = constraintPos;
    return sentData;
  }

  /// Calculates the size the components ideally wants to have.
  Size calculateSize(BuildContext context) {
    double minWidth = (context.findRenderObject() as RenderBox).getMaxIntrinsicWidth(double.infinity).ceilToDouble();
    double minHeight = (context.findRenderObject() as RenderBox).getMaxIntrinsicHeight(double.infinity).ceilToDouble();
    return Size(minWidth, minHeight);
  }

  /// Sends the calc size to the [ILayoutService] and, if possible, triggers a layout cycle.
  void sendCalcSize({required LayoutData pLayoutData, required String pReason}) {
    IUiService().sendCommand(PreferredSizeCommand(layoutData: pLayoutData, reason: pReason));
  }

  /// Creates a save command.
  ///
  /// Will return null if there is nothing to save.
  Future<BaseCommand?> createSaveCommand() async {
    return null;
  }

  /// The top value for [wrapWidget].
  double getTopForPositioned() {
    return layoutData.hasPosition ? layoutData.layoutPosition!.top : 0.0;
  }

  /// The left value for [wrapWidget].
  double getLeftForPositioned() {
    return layoutData.hasPosition ? layoutData.layoutPosition!.left : 0.0;
  }

  /// The width value for [wrapWidget].
  double getWidthForPositioned() {
    return layoutData.hasPosition ? layoutData.layoutPosition!.width : 0.0;
  }

  /// The height value for [wrapWidget].
  double getHeightForPositioned() {
    return layoutData.hasPosition ? layoutData.layoutPosition!.height : 0.0;
  }

  /// Focuses this component.
  void focus() {
    IUiService().sendCommand(SetFocusCommand(componentId: model.id, focus: true, reason: "Sending Focus"));
  }

  /// Unfocuses this component.
  void unfocus() {
    IUiService().sendCommand(SetFocusCommand(componentId: model.id, focus: false, reason: "Sending Focus"));
  }
}
