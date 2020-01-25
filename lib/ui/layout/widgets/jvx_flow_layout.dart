import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';

import '../i_alignment_constants.dart';


class JVxFlowLayoutWidget extends MultiChildRenderObjectWidget {
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Class members
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	// the layout margins.
	final EdgeInsets margins;
	
	// the horizontal gap between components. 
	final int	horizontalGap;
	// the vertical gap between components. */
	final int	verticalGap;

	// the horizontal alignment.
	final int horizontalAlignment;
	// the vertical alignment.
	final int verticalAlignment;
	
	// the orientation.
	final int orientation;

	// the component alignment. */
	final int componentAlignment;

  JVxFlowLayoutWidget({
    Key key,
    List<JVxFlowLayoutConstraintData> children: const [],
    this.margins = EdgeInsets.zero,
    this.horizontalGap = 0,
    this.verticalGap = 0,
    this.horizontalAlignment = 1,
    this.verticalAlignment = 1,
    this.orientation = 0,
    this.componentAlignment = 1 }) : super (key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderJVxFlowLayoutWidget(this.horizontalAlignment, this.verticalAlignment, this.orientation, this.componentAlignment, 
      this.margins, this.horizontalGap, this.verticalGap);
  }

  @override
  void updateRenderObject(BuildContext context, RenderJVxFlowLayoutWidget renderObject) {

    /// Force Layout, if some of the settings have changed
    if (renderObject.horizontalAlignment != this.horizontalAlignment) {
      renderObject.horizontalAlignment = this.horizontalAlignment;
      renderObject.markNeedsLayout();
    }

    if (renderObject.verticalAlignment != this.verticalAlignment) {
      renderObject.verticalAlignment = this.verticalAlignment;
      renderObject.markNeedsLayout();
    }

    if (renderObject.orientation != this.orientation) {
      renderObject.orientation = this.orientation;
      renderObject.markNeedsLayout();
    }

    if (renderObject.componentAlignment != this.componentAlignment) {
      renderObject.componentAlignment = this.componentAlignment;
      renderObject.markNeedsLayout();
    }
    
    if (renderObject.horizontalGap != this.horizontalGap) {
      renderObject.horizontalGap = this.horizontalGap;
      renderObject.markNeedsLayout();
    }

    if (renderObject.verticalGap != this.verticalGap) {
      renderObject.verticalGap = this.verticalGap;
      renderObject.markNeedsLayout();
    }

    if (renderObject.margins != this.margins) {
      renderObject.margins = this.margins;
      renderObject.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(new IntProperty('horizontalAlignment', horizontalAlignment));
    properties.add(new IntProperty('verticalAlignment', verticalAlignment));
    properties.add(new IntProperty('orientation', orientation));
    properties.add(new IntProperty('componentAlignment', componentAlignment));
    properties.add(new IntProperty('horizontalGap', horizontalGap));
    properties.add(new IntProperty('verticalGap', verticalGap));
    properties.add(new StringProperty('margins', margins.toString()));
  }

}

class RenderJVxFlowLayoutWidget extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {

  // Stores all constraints.
	Map<RenderBox, JVxComponent>	constraintMap = <RenderBox, JVxComponent>{};

	// the layout margins.
	EdgeInsets margins;
	
	// the horizontal gap between components. 
	int	horizontalGap;

	// the vertical gap between components. */
	int	verticalGap;

  	// the horizontal alignment.
	int horizontalAlignment = IAlignmentConstants.ALIGN_CENTER;
	// the vertical alignment.
	int verticalAlignment = IAlignmentConstants.ALIGN_CENTER;
	
	// the orientation.
	int orientation = 0;

	// the component alignment. */
	int componentAlignment = 1;

  RenderJVxFlowLayoutWidget(
    this.horizontalAlignment,
    this.verticalAlignment,
    this.orientation,
    this.componentAlignment,
    this.margins ,
    this.horizontalGap,
    this.verticalGap,
    { List<RenderBox> children }) {
      addAll(children);
    }   
}


class JVxFlowLayoutConstraintData extends ParentDataWidget<JVxFlowLayoutWidget> {
  /// Marks a child with a layout identifier.
  ///
  /// Both the child and the id arguments must not be null.
  JVxFlowLayoutConstraintData({
    Key key,
    this.id,
    @required Widget child,
  }) : assert(child != null),
        super(key: key ?? ValueKey<Object>(id), child: child);

  /// An object representing the identity of this child.
  ///
  /// The [id] needs to be unique among the children that the
  /// [CustomMultiChildLayout] manages.
  final JVxComponent id;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is MultiChildLayoutParentData);
    final MultiChildLayoutParentData parentData = renderObject.parentData;
    if (parentData.id != id) {
      parentData.id = id;
      final AbstractNode targetParent = renderObject.parent;
      if (targetParent is RenderObject)
        targetParent.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('id', id));
  }
}