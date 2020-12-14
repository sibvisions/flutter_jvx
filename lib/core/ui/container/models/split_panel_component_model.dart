import 'package:flutter/cupertino.dart';
import 'package:jvx_flutterclient/core/models/api/component/changed_component.dart';
import 'package:jvx_flutterclient/core/models/api/component/component_properties.dart';
import 'package:jvx_flutterclient/core/ui/container/container_component_model.dart';

class SplitPanelComponentModel extends ContainerComponentModel {
  final splitViewKey = GlobalKey();

  final keyFirst = GlobalKey();
  final keySecond = GlobalKey();

  ScrollController scrollControllerView1 =
      ScrollController(keepScrollOffset: true);
  ScrollController scrollControllerView2 =
      ScrollController(keepScrollOffset: true);

  static const VERTICAL = 0;
  static const HORIZONTAL = 1;

  int dividerPosition;
  int dividerAlignment;
  int orientation = HORIZONTAL;

  double currentSplitviewWeight;

  BoxConstraints lastConstraints;

  @override
  get preferredSize {
    if (lastConstraints != null) return lastConstraints.biggest;
    return null;
  }

  SplitPanelComponentModel(
      {ChangedComponent changedComponent, String componentId})
      : super(changedComponent: changedComponent, componentId: componentId);

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    dividerPosition =
        changedComponent.getProperty<int>(ComponentProperty.DIVIDER_POSITION);
    dividerAlignment = changedComponent.getProperty<int>(
        ComponentProperty.DIVIDER_ALIGNMENT, dividerAlignment);
    orientation = changedComponent.getProperty<int>(
        ComponentProperty.ORIENTATION, orientation);

    super.updateProperties(context, changedComponent);

    // print("SplitPanel - DividerPosition: " +
    //     dividerPosition.toString() +
    //     " DividerAlignment: " +
    //     dividerAlignment.toString() +
    //     " Orientation: " +
    //     orientation.toString());
  }
}
