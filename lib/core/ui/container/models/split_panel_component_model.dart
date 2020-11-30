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

  /// Constant for horizontal anchors.
  static const HORIZONTAL = 0;

  /// Constant for vertical anchors.
  static const VERTICAL = 1;

  /// Constant for relative anchors.
  static const RELATIVE = 2;

  int dividerPosition;
  int dividerAlignment;

  double currentSplitviewWeight;

  SplitPanelComponentModel(
      {ChangedComponent changedComponent, String componentId})
      : super(changedComponent: changedComponent, componentId: componentId);

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    dividerPosition =
        changedComponent.getProperty<int>(ComponentProperty.DIVIDER_POSITION);
    dividerAlignment = changedComponent.getProperty<int>(
        ComponentProperty.DIVIDER_ALIGNMENT, HORIZONTAL);
    super.updateProperties(context, changedComponent);
  }
}
