
import 'package:flutter/widgets.dart';
import '../../ui/component/i_component.dart';
import 'i_alignment_constants.dart';
import 'jvx_layout.dart';

class JVxFlowLayoutOld extends JVxLayout<String> {
  /// Constant for horizontal anchors.
  static const HORIZONTAL = 0;

  /// Constant for vertical anchors.
  static const VERTICAL = 1;

  Key key = UniqueKey();
  /// the x-axis alignment (default: {@link JVxConstants#CENTER}). */
	int	horizontalAlignment = IAlignmentConstants.ALIGN_CENTER;
	/// the y-axis alignment (default: {@link JVxConstants#CENTER}). */
	int	verticalAlignment = IAlignmentConstants.ALIGN_CENTER;	
	// the orientation.
	int orientation = HORIZONTAL;
	// the component alignment.
	int componentAlignment = IAlignmentConstants.ALIGN_CENTER;
  /// the auto wrap.
	bool autoWrap = false;

  JVxFlowLayoutOld();

  JVxFlowLayoutOld.fromLayoutString(String layoutString, String layoutData) {
    updateLayoutString(layoutString);
  }

  @override
  void updateLayoutString(String layoutString) {
    parseFromString(layoutString);
    List<String> parameter = layoutString?.split(",");

    orientation = int.parse(parameter[7]);
    horizontalAlignment = int.parse(parameter[8]);
    verticalAlignment = int.parse(parameter[9]);
    componentAlignment = int.parse(parameter[10]);
  }

  void addLayoutComponent(IComponent pComponent, String pConstraint)
  {
    layoutConstraints.putIfAbsent(pComponent, () => pConstraint);
  }

  void removeLayoutComponent(IComponent pComponent) 
  {
    layoutConstraints.remove(pComponent);
  }

    @override
  String getConstraints(IComponent comp) {
    return layoutConstraints[comp];
  }

  Widget getWidget() {
    List<Widget> children = new List<Widget>();
    Axis direction = orientation==VERTICAL?Axis.vertical:Axis.horizontal;

    this.layoutConstraints.forEach((k, v) {
      if (k.isVisible)
        children.add(k.getWidget());
    });

    if (componentAlignment==IAlignmentConstants.ALIGN_STRETCH)
    {
      return Column(
          children: children,
          crossAxisAlignment: IAlignmentConstants.getCrossAxisAlignment(this.horizontalAlignment),);
    } else {
      return Wrap(
        children: children,
        direction: direction,
      );
    }    
  }
}