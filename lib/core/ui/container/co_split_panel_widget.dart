import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/ui/container/models/split_panel_component_model.dart';

import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../component/component_widget.dart';
import '../widgets/custom/split_view.dart';
import 'co_container_widget.dart';
import 'co_scroll_panel_layout.dart';
import 'container_component_model.dart';

class CoSplitPanelWidget extends CoContainerWidget {
  CoSplitPanelWidget({ContainerComponentModel componentModel})
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
        componentModel.currentSplitviewWeight =
            componentModel.dividerPosition / constraints.maxWidth;
      } else if (componentModel.dividerPosition != null &&
          componentModel.dividerPosition >= 0 &&
          constraints.maxHeight != null &&
          componentModel.dividerPosition < constraints.maxHeight &&
          (splitViewMode == SplitViewMode.Vertical)) {
        componentModel.currentSplitviewWeight =
            componentModel.dividerPosition / constraints.maxHeight;
      } else {
        componentModel.currentSplitviewWeight = 0.5;
      }
    }
  }

  SplitViewMode get defaultSplitViewMode {
    return ((widget.componentModel as SplitPanelComponentModel)
                    .dividerAlignment ==
                SplitPanelComponentModel.HORIZONTAL ||
            (widget.componentModel as SplitPanelComponentModel)
                    .dividerAlignment ==
                SplitPanelComponentModel.RELATIVE)
        ? SplitViewMode.Horizontal
        : SplitViewMode.Vertical;
  }

  SplitViewMode get splitViewMode {
    if (kIsWeb &&
        ((widget.componentModel as SplitPanelComponentModel)
                    .appState
                    .layoutMode ==
                'Full' ||
            (widget.componentModel as SplitPanelComponentModel)
                    .appState
                    .layoutMode ==
                'Small')) {
      return defaultSplitViewMode;
    }

    if (defaultSplitViewMode == SplitViewMode.Horizontal) {
      if (MediaQuery.of(context).size.width >= 667) return defaultSplitViewMode;
    } else {
      if (MediaQuery.of(context).size.height >= 667)
        return defaultSplitViewMode;
    }

    return null;
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
      _calculateDividerPosition(constraints, this.splitViewMode);

      if (firstComponent != null) {
        Size preferredSize;

        if (constraints.maxWidth != double.infinity &&
            componentModel.currentSplitviewWeight != null) {
          preferredSize = Size(
              constraints.maxWidth * componentModel.currentSplitviewWeight,
              constraints.maxHeight);
        }

        widgets.add(CoScrollPanelLayout(
          key: componentModel.keyFirst,
          preferredConstraints:
              CoScrollPanelConstraints(constraints, preferredSize),
          container: widget.componentModel,
          children: [
            CoScrollPanelLayoutId(
                key: ValueKey(componentModel.keyFirst),
                constraints:
                    CoScrollPanelConstraints(constraints, preferredSize),
                child: firstComponent)
          ],
        ));
      } else {
        widgets.add(Container());
      }

      if (secondComponent != null) {
        Size preferredSize;
        if (constraints.maxWidth != double.infinity &&
            componentModel.currentSplitviewWeight != null) {
          preferredSize = Size(
              constraints.maxWidth -
                  (constraints.maxWidth *
                      componentModel.currentSplitviewWeight),
              constraints.maxHeight);
        }

        widgets.add(CoScrollPanelLayout(
          key: componentModel.keySecond,
          preferredConstraints:
              CoScrollPanelConstraints(constraints, preferredSize),
          children: [
            CoScrollPanelLayoutId(
                key: ValueKey(componentModel.keySecond),
                constraints:
                    CoScrollPanelConstraints(constraints, preferredSize),
                child: secondComponent)
          ],
        ));
      } else {
        widgets.add(Container());
      }

      if (this.splitViewMode != null) {
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
      } else {
        return SplitView(
          key: componentModel.splitViewKey,
          initialWeight: 0.5,
          showHandle: false,
          view1: widgets[0],
          view2: widgets[1],
          viewMode: SplitViewMode.Vertical,
          scrollControllerView1: componentModel.scrollControllerView1,
          scrollControllerView2: componentModel.scrollControllerView2,
        );
      }
    });
  }
}
