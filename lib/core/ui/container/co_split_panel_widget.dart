import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'models/split_panel_component_model.dart';

import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../component/component_widget.dart';
import '../widgets/custom/split_view.dart';
import 'co_container_widget.dart';
import 'co_scroll_panel_layout.dart';
import 'container_component_model.dart';

class CoSplitPanelWidget extends CoContainerWidget {
  final SplitPanelComponentModel componentModel;

  CoSplitPanelWidget({this.componentModel})
      : super(componentModel: componentModel);

  @override
  State<StatefulWidget> createState() => CoSplitPanelWidgetState();
}

class CoSplitPanelWidgetState extends CoContainerWidgetState {
  void _calculateDividerPosition(
      BoxConstraints constraints, SplitViewMode splitViewMode) {
    SplitPanelComponentModel componentModel = widget.componentModel;

    if (componentModel.currentSplitviewWeight == null) {
      if (componentModel.dividerPosition != null &&
          componentModel.dividerPosition >= 0 &&
          constraints.maxWidth != null &&
          componentModel.dividerPosition < constraints.maxWidth &&
          splitViewMode == SplitViewMode.Horizontal) {
        if (constraints.maxWidth == double.infinity)
          componentModel.currentSplitviewWeight =
              componentModel.dividerPosition /
                  MediaQuery.of(context).size.width;
        else
          componentModel.currentSplitviewWeight =
              componentModel.dividerPosition / constraints.maxWidth;
      } else if (componentModel.dividerPosition != null &&
          componentModel.dividerPosition >= 0 &&
          constraints.maxHeight != null &&
          componentModel.dividerPosition < constraints.maxHeight &&
          (splitViewMode == SplitViewMode.Vertical)) {
        if (constraints.maxWidth == double.infinity)
          componentModel.currentSplitviewWeight =
              componentModel.dividerPosition /
                  MediaQuery.of(context).size.height;
        else
          componentModel.currentSplitviewWeight =
              componentModel.dividerPosition / constraints.maxHeight;
      } else {
        componentModel.currentSplitviewWeight = 0.5;
      }
    }
  }

  SplitViewMode get defaultSplitViewMode {
    SplitPanelComponentModel componentModel = widget.componentModel;
    return (componentModel.orientation == SplitPanelComponentModel.HORIZONTAL)
        ? SplitViewMode.Horizontal
        : SplitViewMode.Vertical;
  }

  SplitViewMode get splitViewMode {
    return defaultSplitViewMode;
    // SplitPanelComponentModel componentModel = widget.componentModel;
    // if (kIsWeb &&
    //     (componentModel.appState.layoutMode == 'Full' ||
    //         componentModel.appState.layoutMode == 'Small')) {
    //   return defaultSplitViewMode;
    // }

    // if (defaultSplitViewMode == SplitViewMode.Horizontal) {
    //   if (MediaQuery.of(context).size.width >= 667) return defaultSplitViewMode;
    // } else {
    //   if (MediaQuery.of(context).size.height >= 667)
    //     return defaultSplitViewMode;
    // }

    // return defaultSplitViewMode;
  }

  @override
  Widget build(BuildContext context) {
    SplitPanelComponentModel componentModel = widget.componentModel;

    ComponentWidget firstComponent =
        componentModel.getComponentWithContraint("FIRST_COMPONENT");
    ComponentWidget secondComponent =
        componentModel.getComponentWithContraint("SECOND_COMPONENT");
    List<Widget> widgets = new List<Widget>();

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      componentModel.lastConstraints = constraints;
      _calculateDividerPosition(constraints, this.splitViewMode);

      widgets.add(firstComponent != null ? firstComponent : Container());
      widgets.add(secondComponent != null ? secondComponent : Container());

      return SplitView(
        key: componentModel.splitViewKey,
        initialWeight: componentModel.currentSplitviewWeight,
        gripColor: Colors.grey[300],
        handleColor: Colors.grey[800].withOpacity(0.5),
        view1: widgets[0],
        view2: widgets[1],
        viewMode: this.splitViewMode,
        onWeightChanged: (value) {
          componentModel.currentSplitviewWeight = value;
        },
        scrollControllerView1: componentModel.scrollControllerView1,
        scrollControllerView2: componentModel.scrollControllerView2,
      );
    });
  }
}
