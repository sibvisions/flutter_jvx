import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  final splitViewKey = GlobalKey();

  final keyFirst = GlobalKey();
  final keySecond = GlobalKey();

  ScrollController scrollControllerView1 =
      ScrollController(keepScrollOffset: true);
  ScrollController scrollControllerView2 =
      ScrollController(keepScrollOffset: true);

  /// Constant for horizontal anchors.
  static const HORIZONTAL = 0;

  /// Constant for vertical anchors.
  static const VERTICAL = 1;

  /// Constant for relative anchors.
  static const RELATIVE = 2;

  int dividerPosition;
  int dividerAlignment;

  double currentSplitviewWeight;

  @override
  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);
    dividerPosition =
        changedComponent.getProperty<int>(ComponentProperty.DIVIDER_POSITION);
    dividerAlignment = changedComponent.getProperty<int>(
        ComponentProperty.DIVIDER_ALIGNMENT, HORIZONTAL);
  }

  void _calculateDividerPosition(
      BoxConstraints constraints, SplitViewMode splitViewMode) {
    if (this.currentSplitviewWeight == null) {
      if (this.dividerPosition != null &&
          this.dividerPosition >= 0 &&
          constraints.maxWidth != null &&
          this.dividerPosition < constraints.maxWidth &&
          splitViewMode == SplitViewMode.Horizontal) {
        this.currentSplitviewWeight =
            this.dividerPosition / constraints.maxWidth;
      } else if (this.dividerPosition != null &&
          this.dividerPosition >= 0 &&
          constraints.maxHeight != null &&
          this.dividerPosition < constraints.maxHeight &&
          (splitViewMode == SplitViewMode.Vertical)) {
        this.currentSplitviewWeight =
            this.dividerPosition / constraints.maxHeight;
      } else {
        this.currentSplitviewWeight = 0.5;
      }
    }
  }

  SplitViewMode get defaultSplitViewMode {
    return (dividerAlignment == HORIZONTAL || dividerAlignment == RELATIVE)
        ? SplitViewMode.Horizontal
        : SplitViewMode.Vertical;
  }

  SplitViewMode get splitViewMode {
    if (kIsWeb &&
        (this.appState.layoutMode == 'Full' || this.appState.layoutMode == 'Small')) {
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
    ComponentWidget firstComponent =
        getComponentWithContraint("FIRST_COMPONENT");
    ComponentWidget secondComponent =
        getComponentWithContraint("SECOND_COMPONENT");
    List<Widget> widgets = new List<Widget>();

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      _calculateDividerPosition(constraints, this.splitViewMode);

      if (firstComponent != null) {
        Size preferredSize;

        if (constraints.maxWidth != double.infinity &&
            this.currentSplitviewWeight != null) {
          preferredSize = Size(
              constraints.maxWidth * this.currentSplitviewWeight,
              constraints.maxHeight);
        }

        widgets.add(CoScrollPanelLayout(
          key: this.keyFirst,
          preferredConstraints:
              CoScrollPanelConstraints(constraints, preferredSize),
          children: [
            CoScrollPanelLayoutId(
                key: ValueKey(this.keyFirst),
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
            this.currentSplitviewWeight != null) {
          preferredSize = Size(
              constraints.maxWidth -
                  (constraints.maxWidth * this.currentSplitviewWeight),
              constraints.maxHeight);
        }

        widgets.add(CoScrollPanelLayout(
          key: this.keySecond,
          preferredConstraints:
              CoScrollPanelConstraints(constraints, preferredSize),
          children: [
            CoScrollPanelLayoutId(
                key: ValueKey(this.keySecond),
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
          key: splitViewKey,
          initialWeight: currentSplitviewWeight,
          gripColor: Colors.grey[300],
          handleColor: Colors.grey[800].withOpacity(0.5),
          view1: widgets[0],
          view2: widgets[1],
          viewMode: this.splitViewMode,
          onWeightChanged: (value) {
            currentSplitviewWeight = value;
          },
          scrollControllerView1: scrollControllerView1,
          scrollControllerView2: scrollControllerView2,
        );
      } else {
        return SplitView(
          key: splitViewKey,
          initialWeight: 0.5,
          showHandle: false,
          view1: widgets[0],
          view2: widgets[1],
          viewMode: SplitViewMode.Vertical,
          scrollControllerView1: scrollControllerView1,
          scrollControllerView2: scrollControllerView2,
        );
      }
    });
  }
}
