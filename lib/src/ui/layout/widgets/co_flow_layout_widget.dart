import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterclient/flutterclient.dart';
import 'package:flutterclient/src/ui/layout/layout/i_layout_model.dart';
import 'package:flutterclient/src/ui/layout/layout/layout_model.dart';

import '../../component/component_widget.dart';
import '../i_alignment_constants.dart';

class CoFlowLayoutWidget extends MultiChildRenderObjectWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  final Map<RenderBox, ComponentWidget> constraintMap =
      <RenderBox, ComponentWidget>{};

  // the layout margins.
  final EdgeInsets? insMargin;

  // the horizontal gap between components.
  final int? horizontalGap;
  // the vertical gap between components. */
  final int? verticalGap;

  // the horizontal alignment.
  final int? horizontalAlignment;
  // the vertical alignment.
  final int? verticalAlignment;

  // the orientation.
  final int? orientation;

  // the component alignment. */
  final int? horizontalComponentAlignment;
  final int? verticalComponentAlignment;

  // the mark to wrap the layout if there is not enough space to show
  // all components (FlowLayout mode).
  final bool? autoWrap;

  final CoContainerWidget? container;

  final LayoutState layoutState;

  CoFlowLayoutWidget(
      {Key? key,
      List<CoFlowLayoutConstraintData> children: const [],
      this.container,
      this.insMargin = EdgeInsets.zero,
      this.horizontalGap = 0,
      this.verticalGap = 0,
      this.horizontalAlignment = 1,
      this.verticalAlignment = 1,
      this.orientation = 0,
      this.horizontalComponentAlignment = 1,
      this.verticalComponentAlignment,
      this.autoWrap = false,
      required this.layoutState})
      : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFlowLayoutWidget(
        this.container,
        this.horizontalAlignment,
        this.verticalAlignment,
        this.orientation,
        this.horizontalComponentAlignment,
        this.verticalComponentAlignment,
        this.insMargin,
        this.horizontalGap,
        this.verticalGap,
        this.autoWrap!,
        this.layoutState);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderFlowLayoutWidget renderObject) {
    /// Force Layout, if some of the settings have changed
    if (this.layoutState == LayoutState.DIRTY) {
      renderObject.markNeedsLayout();
    }

    /// Force Layout, if some of the settings have changed
    if (renderObject.iHorizontalAlignment != this.horizontalAlignment) {
      renderObject.iHorizontalAlignment = this.horizontalAlignment;
      renderObject.markNeedsLayout();
    }

    if (renderObject.iVerticalAlignment != this.verticalAlignment) {
      renderObject.iVerticalAlignment = this.verticalAlignment;
      renderObject.markNeedsLayout();
    }

    if (renderObject.iOrientation != this.orientation) {
      renderObject.iOrientation = this.orientation;
      renderObject.markNeedsLayout();
    }

    if (renderObject.iHorizontalComponentAlignment !=
        this.horizontalComponentAlignment) {
      renderObject.iHorizontalComponentAlignment =
          this.horizontalComponentAlignment;
      renderObject.markNeedsLayout();
    }

    if (renderObject.iVerticalComponentAlignment !=
        this.verticalComponentAlignment) {
      renderObject.iVerticalComponentAlignment =
          this.verticalComponentAlignment;
      renderObject.markNeedsLayout();
    }

    if (renderObject.iHorizontalGap != this.horizontalGap) {
      renderObject.iHorizontalGap = this.horizontalGap;
      renderObject.markNeedsLayout();
    }

    if (renderObject.iVerticalGap != this.verticalGap) {
      renderObject.iVerticalGap = this.verticalGap;
      renderObject.markNeedsLayout();
    }

    if (renderObject.insMargins != this.insMargin) {
      renderObject.insMargins = this.insMargin;
      renderObject.markNeedsLayout();
    }

    if (renderObject.bAutoWrap != this.autoWrap) {
      renderObject.bAutoWrap = this.autoWrap!;
      renderObject.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(new IntProperty('horizontalAlignment', horizontalAlignment));
    properties.add(new IntProperty('verticalAlignment', verticalAlignment));
    properties.add(new IntProperty('orientation', orientation));
    properties.add(new IntProperty(
        'horizontalComponentAlignment', horizontalComponentAlignment));
    properties.add(new IntProperty(
        'verticalComponentAlignment', verticalComponentAlignment));
    properties.add(new IntProperty('horizontalGap', horizontalGap));
    properties.add(new IntProperty('verticalGap', verticalGap));
    properties.add(new StringProperty('margins', insMargin.toString()));
  }
}

class RenderFlowLayoutWidget extends CoLayoutRenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  // Stores all constraints.
  Map<RenderBox, ComponentWidget> constraintMap =
      <RenderBox, ComponentWidget>{};

  // the layout margins.
  EdgeInsets? insMargins;

  // the horizontal gap between components.
  int? iHorizontalGap;

  // the vertical gap between components. */
  int? iVerticalGap;

  // the horizontal alignment.
  int? iHorizontalAlignment = IAlignmentConstants.ALIGN_CENTER;
  // the vertical alignment.
  int? iVerticalAlignment = IAlignmentConstants.ALIGN_CENTER;

  // the orientation.
  int? iOrientation = 0;

  // the component alignment. */
  int? iHorizontalComponentAlignment = IAlignmentConstants.ALIGN_CENTER;
  int? iVerticalComponentAlignment = IAlignmentConstants.ALIGN_CENTER;

  Rect? lastPreferredSizeCalculation;

  CoContainerWidget? container;

  LayoutState layoutState;

  /* 
	 * the mark to wrap the layout if there is not enough space to show 
	 * all components (FlowLayout mode).
	 */
  bool bAutoWrap = false;

  RenderFlowLayoutWidget(
      this.container,
      this.iHorizontalAlignment,
      this.iVerticalAlignment,
      this.iOrientation,
      this.iHorizontalComponentAlignment,
      this.iVerticalComponentAlignment,
      this.insMargins,
      this.iHorizontalGap,
      this.iVerticalGap,
      this.bAutoWrap,
      this.layoutState,
      {List<RenderBox>? children}) {
    addAll(children);
  }

  @override
  void performLayout() {
    this.debugInfo =
        "FlowLayout in container ${container!.componentModel.componentId}";
    // Set components
    constraintMap = <RenderBox, ComponentWidget>{};
    RenderBox? child = firstChild;
    while (child != null) {
      final MultiChildLayoutParentData childParentData =
          child.parentData as MultiChildLayoutParentData;
      addLayoutComponent(child, childParentData.id!);

      child = childParentData.nextSibling;
    }

    LayoutModel layoutModel =
        (container?.componentModel as ContainerComponentModel)
            .layout!
            .layoutModel;

    // calculate preferred, minimum and maximum layout sizes for parent layouts
    preferredLayoutSize = layoutModel.layoutPreferredSize[this.constraints];
    if (preferredLayoutSize == null) {
      preferredLayoutSize = _preferredLayoutSize(
          container?.componentModel as ContainerComponentModel);
      if (preferredLayoutSize != null)
        layoutModel.layoutPreferredSize[this.constraints] =
            preferredLayoutSize!;
    }

    minimumLayoutSize = layoutModel.layoutMinimumSize[this.constraints];
    if (minimumLayoutSize == null) {
      minimumLayoutSize = _minimumLayoutSize(
          container?.componentModel as ContainerComponentModel);
      if (minimumLayoutSize != null)
        layoutModel.layoutMinimumSize[this.constraints] = minimumLayoutSize!;
    }

    Size dimSize = this.constraints.biggest;
    dimSize = Size(dimSize.width - (insMargins!.left + insMargins!.right),
        dimSize.height - (insMargins!.top + insMargins!.bottom));

    //x stores the columns
    //y stores the rows
    Rect rectCompInfo =
        calculateGrid(container?.componentModel as ContainerComponentModel);

    //ignore the insets!
    Size dimPref = new Size(
        rectCompInfo.width * rectCompInfo.left +
            iHorizontalGap! * (rectCompInfo.left - 1),
        rectCompInfo.height * rectCompInfo.top +
            iVerticalGap! * (rectCompInfo.top - 1));

    if (dimSize.height == double.infinity)
      dimSize = Size(dimSize.width, dimPref.height);
    if (dimSize.width == double.infinity)
      dimSize = Size(dimPref.width, dimSize.height);

    int iLeft;
    int iWidth;

    if (iHorizontalAlignment == IAlignmentConstants.ALIGN_STRETCH) {
      iLeft = insMargins!.left.round();
      iWidth = dimSize.width.round();
    } else {
      //align the layout in the container
      iLeft = (((dimSize.width - dimPref.width) *
                  getAlignmentFactor(iHorizontalAlignment!)) +
              insMargins!.left)
          .round();
      iWidth = dimPref.width.round();
    }

    int iTop;
    int iHeight;

    if (iVerticalAlignment == IAlignmentConstants.ALIGN_STRETCH) {
      iTop = insMargins!.top.round();
      iHeight = dimSize.height.round();
    } else {
      //align the layout in the container
      iTop = (((dimSize.height - dimPref.height) *
                  getAlignmentFactor(iVerticalAlignment!)) +
              insMargins!.top)
          .round();
      iHeight = dimPref.height.round();
    }

    int fW = max<int>(1, iWidth);
    int fPW = max<int>(1, dimPref.width.round());
    int fH = max<int>(1, iHeight);
    int fPH = max<int>(1, dimPref.height.round());
    int x = 0;
    int y = 0;

    ComponentWidget comp;

    bool bFirst = true;
    for (int i = 0, anz = constraintMap.length; i < anz; i++) {
      comp = constraintMap.values.elementAt(i);

      if (comp.componentModel.isVisible) {
        Size size =
            this.getPreferredSize(constraintMap.keys.elementAt(i), comp);

        if (iOrientation == 0) {
          if (!bFirst &&
              bAutoWrap &&
              dimSize.width > 0 &&
              x + size.width > dimSize.width) {
            x = 0;
            y += ((rectCompInfo.height + iVerticalGap!) * fH / fPH).round();
          } else if (bFirst) {
            bFirst = false;
          }

          if (iVerticalComponentAlignment ==
              IAlignmentConstants.ALIGN_STRETCH) {
            double offsetX = iLeft + x * fW / fPW;
            double offsetY = (iTop + y).toDouble();
            double width = size.width * fW / fPW;
            double height = rectCompInfo.height * fH / fPH;

            constraintMap.keys.elementAt(i).layout(
                BoxConstraints(
                    minWidth: width,
                    maxWidth: width,
                    minHeight: height,
                    maxHeight: height),
                parentUsesSize: true);

            final MultiChildLayoutParentData childParentData =
                constraintMap.keys.elementAt(i).parentData
                    as MultiChildLayoutParentData;
            childParentData.offset = Offset(offsetX, offsetY);
          } else {
            double offsetX = iLeft + x * fW / fPW;
            double offsetY = iTop +
                y +
                ((rectCompInfo.height - size.height) *
                        getAlignmentFactor(iVerticalComponentAlignment!)) *
                    fH /
                    fPH;
            double width = size.width * fW / fPW;
            double height = size.height * fH / fPH;

            constraintMap.keys.elementAt(i).layout(
                BoxConstraints(
                    minWidth: width,
                    maxWidth: width,
                    minHeight: height,
                    maxHeight: height),
                parentUsesSize: true);

            final MultiChildLayoutParentData childParentData =
                constraintMap.keys.elementAt(i).parentData
                    as MultiChildLayoutParentData;
            childParentData.offset = Offset(offsetX, offsetY);
          }

          x += (size.width + iHorizontalGap!).round();
        } else {
          if (!bFirst &&
              bAutoWrap &&
              dimSize.height > 0 &&
              y + size.height > dimSize.height) {
            y = 0;
            x += ((rectCompInfo.width + iHorizontalGap!) * fW / fPW).round();
          } else if (bFirst) {
            bFirst = false;
          }

          if (iHorizontalComponentAlignment ==
              IAlignmentConstants.ALIGN_STRETCH) {
            double offsetX = (iLeft + x).toDouble();
            double offsetY = iTop + y * fH / fPH;
            double width = rectCompInfo.width * fW / fPW;
            double height = size.height * fH / fPH;

            constraintMap.keys.elementAt(i).layout(
                BoxConstraints(
                    minWidth: width,
                    maxWidth: width,
                    minHeight: height,
                    maxHeight: height),
                parentUsesSize: true);

            final MultiChildLayoutParentData childParentData =
                constraintMap.keys.elementAt(i).parentData
                    as MultiChildLayoutParentData;
            childParentData.offset = Offset(offsetX, offsetY);
          } else {
            double offsetX = iLeft +
                x +
                ((rectCompInfo.width - size.width) *
                        getAlignmentFactor(iHorizontalComponentAlignment!)) *
                    fW /
                    fPW;
            double offsetY = iTop + y * fH / fPH;
            double width = size.width * fW / fPW;
            double height = size.height * fH / fPH;

            constraintMap.keys.elementAt(i).layout(
                BoxConstraints(
                    minWidth: width,
                    maxWidth: width,
                    minHeight: height,
                    maxHeight: height),
                parentUsesSize: true);

            final MultiChildLayoutParentData childParentData =
                constraintMap.keys.elementAt(i).parentData
                    as MultiChildLayoutParentData;
            childParentData.offset = Offset(offsetX, offsetY);
          }

          y += (size.height + iVerticalGap!).round();
        }
      }

      if (this.constraints.hasBoundedHeight &&
          this.constraints.hasBoundedWidth &&
          constraintMap.values.elementAt(i) is CoContainerWidget) {
        (constraintMap.values.elementAt(i).componentModel
                as ContainerComponentModel)
            .layout!
            .layoutModel
            .layoutState = LayoutState.RENDERED;
      }
    }

    this.size =
        this.constraints.constrainDimensions(fW.toDouble(), fH.toDouble());

    if (this.constraints.hasBoundedHeight && this.constraints.hasBoundedWidth) {
      layoutState = LayoutState.RENDERED;
    }

    dev.log(
        "FlowLayout in container ${container!.componentModel.name} (${container!.componentModel.componentId}) with ${constraintMap.length} children and with constraints ${this.constraints} render size ${this.size.toString()}");
  }

  /*
	 * Calculates the width, height, row and column count for the current components
	 * of a container.
	 * 
	 * @param pContainer the container to be layouted
	 * @return a rectangle with width, height, column count (stored in x) and row count
	 *         (stored in y)
	 */
  Rect calculateGrid(ContainerComponentModel pParent) {
    int iWidth = 0;
    int iHeight = 0;

    int iCalcWidth = 0;
    int iCalcHeight = 0;

    int iAnzRows = 1;
    int iAnzCols = 1;

    Size bounds = this.constraints.biggest;
    bounds = Size(bounds.width - (insMargins!.left + insMargins!.right),
        bounds.height - (insMargins!.top + insMargins!.bottom));

    /*if (pContainer.getParent() instanceof JViewport)
		{
			Dimension dim = pContainer.getParent().getSize();
			
			if (dim.width < bounds.width)
			{
				bounds.width = dim.width;
			}
			if (dim.height < bounds.height)
			{
				bounds.height = dim.height;
			}
		}*/

    ComponentWidget comp;

    //needed because the visible state of the component will be checked!
    bool bFirst = true;

    for (int i = 0, anz = constraintMap.length; i < anz; i++) {
      comp = constraintMap.values.elementAt(i);

      if (comp.componentModel.isVisible) {
        Size dimPref =
            this.getPreferredSize(constraintMap.keys.elementAt(i), comp);

        if (iOrientation == 0) {
          if (!bFirst) {
            iCalcWidth += iHorizontalGap!;
          }

          iCalcWidth += dimPref.width.round();
          iHeight = max<int>(iHeight, dimPref.height.round());

          //wrapping doesn't change the height, because the height will be used
          //for all rows
          if (!bFirst &&
              bAutoWrap &&
              bounds.width > 0 &&
              iCalcWidth > bounds.width) {
            iCalcWidth = dimPref.width.round();
            iAnzRows++;
          } else if (bFirst) {
            bFirst = false;
          }

          iWidth = max<int>(iWidth, iCalcWidth);
        } else {
          if (!bFirst) {
            iCalcHeight += iVerticalGap!;
          }

          iWidth = max<int>(iWidth, dimPref.width.round());
          iCalcHeight += dimPref.height.round();

          //wrapping doesn't change the width, because the width will be used
          //for all columns
          if (!bFirst &&
              bAutoWrap &&
              bounds.height > 0 &&
              iCalcHeight > bounds.height) {
            iCalcHeight = dimPref.height.round();
            iAnzCols++;
          } else if (bFirst) {
            bFirst = false;
          }

          iHeight = max<int>(iHeight, iCalcHeight);
        }
      }
    }

    return new Rect.fromLTWH(iAnzCols.toDouble(), iAnzRows.toDouble(),
        iWidth.toDouble(), iHeight.toDouble());
  }

  /*
	 * Gets the factor for an alignment value. The factor will be used
	 * to align the components in the layout.
	 * 
	 * @param pAlign the alignment e.g {@link JVxConstants#LEFT}, {@link JVxConstants#CENTER}, {@link JVxConstants#RIGHT} 
	 * @return the factor for the alignment e.g <code>0f</code>, <code>0.5f</code>, <code>1f</code>
	 * @throws IllegalArgumentException if the alignment is unknown or not allowed
	 */
  double getAlignmentFactor(int pAlign) {
    switch (pAlign) {
      case 0:
        return 0.0;
      case 1:
        return 0.5;
      case 2:
        return 1.0;
      default:
        throw new ArgumentError("Invalid alignment: " + pAlign.toString());
    }
  }

  Size getPreferredSize(RenderBox renderBox, ComponentWidget comp) {
    if (!comp.componentModel.isPreferredSizeSet) {
      Size? size = getChildLayoutPreferredSize(comp, this.constraints);
      if (size != null) {
        return size;
      } else {
        if (renderBox.hasSize && !_isLayoutDirty(comp))
          size = renderBox.size;
        else
          size = layoutRenderBox(renderBox, constraints);

        if (size.width == double.infinity || size.height == double.infinity) {
          print(
              "CoFlowLayout: getPrefererredSize: Infinity height or width for BorderLayout!");
        }
        return size;
      }
    } else {
      return comp.componentModel.preferredSize!;
    }
  }

  bool _isLayoutDirty(ComponentWidget componentWidget) {
    if (componentWidget is CoContainerWidget) {
      ContainerComponentModel containerComponentModel =
          componentWidget.componentModel as ContainerComponentModel;

      if (containerComponentModel.layout != null &&
          containerComponentModel.layout!.layoutModel.layoutState ==
              LayoutState.DIRTY) {
        // containerComponentModel.layout!.layoutModel.layoutState =
        //     LayoutState.RENDERED;
        return true;
      }
    }

    return false;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData)
      child.parentData = MultiChildLayoutParentData();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(HitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result as BoxHitTestResult,
        position: position);
  }

  void addLayoutComponent(RenderBox pComp, Object pConstraints) {
    ArgumentError.checkNotNull(
        pConstraints, "The constraints must not be null.");

    if (pConstraints is ComponentWidget) {
      setConstraints(pComp, pConstraints);
    } else {
      throw new ArgumentError(
          "Illegal constraint type " + pConstraints.runtimeType.toString());
    }
  }

  /*
	 * Puts the component and its constraints into the constraint Map.
	 * 
	 * @param pComponent the component
	 * @param pConstraints the components constraints
	 */
  void setConstraints(RenderBox pComponent, ComponentWidget pConstraints) {
    ArgumentError.checkNotNull(pComponent, "The component must not be null.");
    ArgumentError.checkNotNull(
        pConstraints, "The constraints must not be null.");

    constraintMap.putIfAbsent(pComponent, () => pConstraints);
  }

  Size _preferredLayoutSize(ContainerComponentModel pContainer) {
    EdgeInsets insets = pContainer.layout != null
        ? pContainer.layout!.layoutModel.margins
        : EdgeInsets.all(0);

    //x stores the columns
    //y stores the rows
    Rect rectCompInfo = calculateGrid(pContainer);
    lastPreferredSizeCalculation = rectCompInfo;
    return new Size(
        rectCompInfo.width * rectCompInfo.left +
            (iHorizontalGap != null ? iHorizontalGap! : 0) *
                (rectCompInfo.left - 1) +
            insets.left +
            insets.right +
            (insMargins != null ? insMargins!.left : 0) +
            (insMargins != null ? insMargins!.right : 0),
        rectCompInfo.height * rectCompInfo.top +
            (iVerticalGap != null ? iVerticalGap! : 0) *
                (rectCompInfo.top - 1) +
            insets.top +
            insets.bottom +
            (insMargins != null ? insMargins!.top : 0) +
            (insMargins != null ? insMargins!.bottom : 0));
  }

  Size _minimumLayoutSize(ContainerComponentModel target) {
    return new Size(0, 0);
  }
}

class CoFlowLayoutConstraintData
    extends ParentDataWidget<MultiChildLayoutParentData> {
  /// Marks a child with a layout identifier.
  ///
  /// Both the child and the id arguments must not be null.
  CoFlowLayoutConstraintData({
    Key? key,
    required this.id,
    required Widget child,
  }) : super(key: key ?? ValueKey<Object>(id), child: child);

  /// An object representing the identity of this child.
  ///
  /// The [id] needs to be unique among the children that the
  /// [CustomMultiChildLayout] manages.
  final ComponentWidget id;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is MultiChildLayoutParentData);
    final MultiChildLayoutParentData parentData =
        renderObject.parentData as MultiChildLayoutParentData;
    if (parentData.id != id) {
      parentData.id = id;
      final AbstractNode targetParent = renderObject.parent!;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('id', id));
  }

  @override
  Type get debugTypicalAncestorWidgetClass => MultiChildLayoutParentData;
}
