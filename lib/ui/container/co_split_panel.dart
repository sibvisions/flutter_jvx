import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../ui/screen/so_component_creator.dart';
import '../../ui/widgets/split_view.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../component/component.dart';
import 'co_scroll_panel_layout.dart';
import 'i_container.dart';
import 'co_container.dart';
import '../../utils/globals.dart' as globals;

class CoSplitPanel extends CoContainer implements IContainer {
  Key keyFirst = GlobalKey();
  Key keySecond = GlobalKey();

  /// Constant for horizontal anchors.
  static const HORIZONTAL = 0;

  /// Constant for vertical anchors.
  static const VERTICAL = 1;

  /// Constant for relative anchors.
  static const RELATIVE = 2;

  int dividerPosition;
  int dividerAlignment;

  double currentSplitviewWeight;

  CoSplitPanel(GlobalKey componentId, BuildContext context)
      : super(componentId, context);

  factory CoSplitPanel.withCompContext(ComponentContext componentContext) {
    return CoSplitPanel(componentContext.globalKey, componentContext.context);
  }

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
          splitViewMode == SplitViewMode.Horizontal) {
        this.currentSplitviewWeight =
            this.dividerPosition / constraints.maxWidth;
      } else if (this.dividerPosition != null &&
          this.dividerPosition >= 0 &&
          constraints.maxHeight != null &&
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
        (globals.layoutMode == 'Full' || globals.layoutMode == 'Small')) {
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

  Widget getWidget() {
    Component firstComponent = getComponentWithContraint("FIRST_COMPONENT");
    Component secondComponent = getComponentWithContraint("SECOND_COMPONENT");
    List<Widget> widgets = new List<Widget>();

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (firstComponent != null) {
        widgets.add(SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: CoScrollPanelLayout(
              key: this.keyFirst,
              parentConstraints: constraints,
              children: [
                CoScrollPanelLayoutId(
                    key: ValueKey(this.keyFirst),
                    parentConstraints: constraints,
                    child: firstComponent.getWidget())
              ],
            )));
      } else {
        widgets.add(Container());
      }

      if (secondComponent != null) {
        widgets.add(SingleChildScrollView(
            //scrollDirection: Axis.horizontal,
            child: CoScrollPanelLayout(
          key: this.keySecond,
          parentConstraints: constraints,
          children: [
            CoScrollPanelLayoutId(
                key: ValueKey(this.keySecond),
                parentConstraints: constraints,
                child: secondComponent.getWidget())
          ],
        )));
      } else {
        widgets.add(Container());
      }

      if (this.splitViewMode != null) {
        _calculateDividerPosition(constraints, this.splitViewMode);

        return SplitView(
          initialWeight: currentSplitviewWeight,
          gripColor: Colors.grey.withOpacity(0.3),
          handleColor: Colors.grey[800].withOpacity(0.5),
          view1: widgets[0],
          view2: widgets[1],
          viewMode:
              (dividerAlignment == HORIZONTAL || dividerAlignment == RELATIVE)
                  ? SplitViewMode.Horizontal
                  : SplitViewMode.Vertical,
          onWeightChanged: (value) {
            currentSplitviewWeight = value;
          },
        );
      } else {
        if (dividerAlignment == HORIZONTAL || dividerAlignment == RELATIVE) {
          return SingleChildScrollView(
              child: Wrap(key: componentId, children: widgets));
        } else {
          return Column(
            key: componentId,
            children: widgets,
          );
        }
      }
    });
  }
}
