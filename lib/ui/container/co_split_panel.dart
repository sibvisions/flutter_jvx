import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../ui/widgets/split_view.dart';
import '../../model/changed_component.dart';
import '../../model/properties/component_properties.dart';
import '../component/component.dart';
import 'i_container.dart';
import 'co_container.dart';
import '../../utils/globals.dart' as globals;

class CoSplitPanel extends CoContainer implements IContainer {
  /// Constant for horizontal anchors.
  static const HORIZONTAL = 0;

  /// Constant for vertical anchors.
  static const VERTICAL = 1;

  /// Constant for relative anchors.
  static const RELATIVE = 2;

  int dividerPosition;
  int dividerAlignment;

  double currentSplitviewWeight = 0.5;

  CoSplitPanel(GlobalKey componentId, BuildContext context)
      : super(componentId, context);

  void updateProperties(ChangedComponent changedComponent) {
    super.updateProperties(changedComponent);
    dividerPosition =
        changedComponent.getProperty<int>(ComponentProperty.DIVIDER_POSITION);
    dividerAlignment = changedComponent.getProperty<int>(
        ComponentProperty.DIVIDER_ALIGNMENT, HORIZONTAL);
  }

  Widget getWidget() {
    Component firstComponent = getComponentWithContraint("FIRST_COMPONENT");
    Component secondComponent = getComponentWithContraint("SECOND_COMPONENT");
    List<Widget> widgets = new List<Widget>();

    if (firstComponent != null) {
      widgets.add(SingleChildScrollView(
          scrollDirection: Axis.horizontal, child: firstComponent.getWidget()));
    } else {
      widgets.add(Container());
    }

    if (secondComponent != null) {
      widgets.add(SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: secondComponent.getWidget()));
    } else {
      widgets.add(Container());
    }

    if (kIsWeb && globals.layoutMode == 'Full') {
      return SplitView(
        initialWeight: currentSplitviewWeight,
        gripColor: Colors.black,
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
  }
}
