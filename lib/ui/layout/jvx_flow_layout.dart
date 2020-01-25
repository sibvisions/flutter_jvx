import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/ui/component/i_component.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';
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
	int componentAlignment = 1;

  /// stores all constraints. */
  Map<JVxComponent, String> _constraintMap= <JVxComponent, String>{};

  JVxFlowLayout(this.key);

  JVxFlowLayout.fromLayoutString(String layoutString, String layoutData) {
    updateLayoutString(layoutString);

    List<String> parameter = layoutString?.split(",");

    orientation = int.parse(parameter[7]);
    horizontalAlignment = int.parse(parameter[8]);
    verticalAlignment = int.parse(parameter[9]);
    componentAlignment = int.parse(parameter[10]);
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
    return Container();
  }

}