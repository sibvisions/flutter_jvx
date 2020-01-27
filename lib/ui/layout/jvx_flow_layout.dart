import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/ui/component/i_component.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';
import 'package:jvx_mobile_v3/ui/layout/widgets/jvx_flow_layout.dart';
import 'i_alignment_constants.dart';
import 'jvx_layout.dart';

class JVxFlowLayout extends JVxLayout<String> {
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

  /// stores all constraints. */
  Map<JVxComponent, String> _constraintMap= <JVxComponent, String>{};

  JVxFlowLayout(this.key);

  JVxFlowLayout.fromLayoutString(String layoutString, String layoutData) {
    updateLayoutString(layoutString);

    List<String> parameter = layoutString?.split(",");

    orientation = int.parse(parameter[7]);
    horizontalAlignment = int.parse(parameter[8]);
    verticalAlignment = int.parse(parameter[9]);
    horizontalComponentAlignment = int.parse(parameter[10]);
    verticalComponentAlignment = horizontalComponentAlignment;
  }

  void updateLayoutString(String layoutString) {
    parseFromString(layoutString);
  }

  void addLayoutComponent(IComponent pComponent, String pConstraint)
  {
      _constraintMap.putIfAbsent(pComponent, () => pConstraint);
  }

  void removeLayoutComponent(IComponent pComponent) 
  {
    _constraintMap.removeWhere((c, s) => c.componentId.toString() == pComponent.componentId.toString());
  }
  
  @override
  String getConstraints(IComponent comp) {
    return _constraintMap[comp];
  }

  Widget getWidget() {
    List<JVxFlowLayoutConstraintData> children = new List<JVxFlowLayoutConstraintData>();

    this._constraintMap.forEach((k, v) {
      if (k.isVisible) {
          children.add(
            new JVxFlowLayoutConstraintData(child: k.getWidget(), 
                  id: k));
      }
    });

    return Container(
      child: JVxFlowLayoutWidget(
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
      ));
  }

}