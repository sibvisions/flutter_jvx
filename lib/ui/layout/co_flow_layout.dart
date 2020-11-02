import 'package:flutter/widgets.dart';
import '../component/i_component.dart';
import '../component/component.dart';
import 'widgets/co_flow_layout_widget.dart';
import '../container/i_container.dart';
import 'i_alignment_constants.dart';
import 'co_layout.dart';

class CoFlowLayout extends CoLayout<String> {
  Key key = UniqueKey();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // the horizontal alignment.
  int horizontalAlignment = IAlignmentConstants.ALIGN_CENTER;
  // the vertical alignment.
  int verticalAlignment = IAlignmentConstants.ALIGN_CENTER;

  // the orientation.
  int orientation = 0;

  // the component alignment. */
  int horizontalComponentAlignment = IAlignmentConstants.ALIGN_CENTER;
  int verticalComponentAlignment = IAlignmentConstants.ALIGN_CENTER;

  bool autoWrap = false;

  /// stores all constraints. */
  Map<Component, String> _constraintMap = <Component, String>{};

  CoFlowLayout(Key key) : super(key);

  CoFlowLayout.fromLayoutString(
      IContainer pContainer, String layoutString, String layoutData)
      : super.fromLayoutString(pContainer, layoutString, layoutData) {
    updateLayoutString(layoutString);
  }

  void updateLayoutString(String layoutString) {
    super.updateLayoutString(layoutString);
    parseFromString(layoutString);

    List<String> parameter = layoutString?.split(",");

    orientation = int.parse(parameter[7]);
    horizontalAlignment = int.parse(parameter[8]);
    verticalAlignment = int.parse(parameter[9]);
    horizontalComponentAlignment = int.parse(parameter[10]);
    autoWrap = (parameter[11] == 'true') ? true : false;
    verticalComponentAlignment = horizontalComponentAlignment;
  }

  void addLayoutComponent(IComponent pComponent, String pConstraint) {
    _constraintMap.putIfAbsent(pComponent, () => pConstraint);
  }

  void removeLayoutComponent(IComponent pComponent) {
    _constraintMap.removeWhere((c, s) =>
        c.componentId.toString() == pComponent.componentId.toString());
  }

  @override
  String getConstraints(IComponent comp) {
    return _constraintMap[comp];
  }

  Widget getWidget() {
    List<CoFlowLayoutConstraintData> children =
        new List<CoFlowLayoutConstraintData>();

    this._constraintMap.forEach((k, v) {
      if (k.isVisible) {
        children
            .add(new CoFlowLayoutConstraintData(child: k.getWidget(), id: k));
      }
    });

    return Container(
        child: CoFlowLayoutWidget(
      key: key,
      children: children,
      insMargin: margins,
      horizontalGap: horizontalGap,
      verticalGap: verticalGap,
      horizontalAlignment: horizontalAlignment,
      verticalAlignment: verticalAlignment,
      orientation: orientation,
      horizontalComponentAlignment: horizontalComponentAlignment,
      verticalComponentAlignment: verticalComponentAlignment,
      autoWrap: autoWrap,
    ));
  }
}
