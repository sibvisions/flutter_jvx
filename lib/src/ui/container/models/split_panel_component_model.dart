import 'package:flutter/cupertino.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/component/changed_component.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/component/component_properties.dart';

import 'container_component_model.dart';

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

  int? dividerPosition;
  int? dividerAlignment;
  int orientation = HORIZONTAL;

  double? currentSplitviewWeight;

  BoxConstraints? lastConstraints;

  @override
  get preferredSize {
    if (lastConstraints != null) return lastConstraints!.biggest;
    return null;
  }

  SplitPanelComponentModel({required ChangedComponent changedComponent})
      : super(
          changedComponent: changedComponent,
        );

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    dividerPosition = changedComponent.getProperty<int>(
        ComponentProperty.DIVIDER_POSITION, dividerPosition);
    dividerAlignment = changedComponent.getProperty<int>(
        ComponentProperty.DIVIDER_ALIGNMENT, dividerAlignment);
    orientation = changedComponent.getProperty<int>(
        ComponentProperty.ORIENTATION, orientation)!;

    super.updateProperties(context, changedComponent);

    // print("SplitPanel - DividerPosition: " +
    //     dividerPosition.toString() +
    //     " DividerAlignment: " +
    //     dividerAlignment.toString() +
    //     " Orientation: " +
    //     orientation.toString());
  }
}
