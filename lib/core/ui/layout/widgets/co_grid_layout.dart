import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../container/co_container_widget.dart';
import '../../container/container_component_model.dart';
import 'co_grid_layout_constraint.dart';
import 'co_layout_render_box.dart';

///
/// The GridLayout class is a layout manager that lays out a container's components in a rectangular grid.
///
/// @author Thomas Lehner, ported by Jürgen Hörmann
///
class CoGridLayoutWidget extends MultiChildRenderObjectWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // the layout margins.
  final EdgeInsets margins;

  // The number of rows.
  final int rows;

  // The number of columns.
  final int columns;

  // the horizontal gap between components.
  final int horizontalGap;

  // the vertical gap between components. */
  final int verticalGap;

  final CoContainerWidget container;

  CoGridLayoutWidget(
      {Key key,
      this.container,
      List<CoGridLayoutConstraintData> children: const [],
      this.rows = 1,
      this.columns = 1,
      this.margins = EdgeInsets.zero,
      this.horizontalGap = 0,
      this.verticalGap = 0})
      : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderGridLayoutWidget(this.container, this.rows, this.columns,
        this.margins, this.horizontalGap, this.verticalGap);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderGridLayoutWidget renderObject) {
    /// Force Layout, if some of the settings have changed
    if (renderObject.rows != this.rows) {
      renderObject.rows = this.rows;
      renderObject.markNeedsLayout();
    }

    if (renderObject.columns != this.columns) {
      renderObject.columns = this.columns;
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
    properties.add(new IntProperty('rows', rows));
    properties.add(new IntProperty('columns', columns));
    properties.add(new IntProperty('horizontalGap', horizontalGap));
    properties.add(new IntProperty('verticalGap', verticalGap));
    properties.add(new StringProperty('margins', margins.toString()));
  }
}

class RenderGridLayoutWidget extends CoLayoutRenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  // Stores all constraints.
  Map<RenderBox, CoGridLayoutConstraints> constraintMap =
      <RenderBox, CoGridLayoutConstraints>{};

  // the layout margins.
  EdgeInsets margins;

  // The number of rows.
  int rows;

  // The number of columns.
  int columns;

  // the horizontal gap between components.
  int horizontalGap;

  // the vertical gap between components. */
  int verticalGap;

  // cache for x-coordinates.
  List<int> xPosition;

  // cache for y-coordinates.
  List<int> yPosition;

  CoContainerWidget container;

  RenderGridLayoutWidget(this.container, this.rows, this.columns, this.margins,
      this.horizontalGap, this.verticalGap,
      {List<RenderBox> children}) {
    addAll(children);
  }

  @override
  void performLayout() {
    // Set components
    constraintMap = <RenderBox, CoGridLayoutConstraints>{};
    RenderBox child = firstChild;
    while (child != null) {
      final MultiChildLayoutParentData childParentData = child.parentData;
      addLayoutComponent(child, childParentData.id);

      child = childParentData.nextSibling;
    }

    preferredLayoutSize = _preferredLayoutSize(container.componentModel);
    minimumLayoutSize = _minimumLayoutSize(container.componentModel);
    maximumLayoutSize = _maximumLayoutSize(container.componentModel);

    Size size = this.constraints.biggest;
    int targetColumns = columns;
    int targetRows = rows;

    if (size.width == double.infinity || size.height == double.infinity)
      size = preferredLayoutSize;

    if (columns <= 0 || rows <= 0) {
      constraintMap?.forEach((component, constraints) {
        if (columns <= 0 &&
            constraints.gridX + constraints.gridWidth > targetColumns) {
          targetColumns = constraints.gridX + constraints.gridWidth;
        }
        if (rows <= 0 &&
            constraints.gridY + constraints.gridHeight > targetRows) {
          targetRows = constraints.gridY + constraints.gridHeight;
        }
      });
    }

    if (targetColumns > 0 && targetRows > 0) {
      int leftInsets = margins.left.round();
      int topInsets = margins.top.round();

      int totalGapsWidth = (targetColumns - 1) * horizontalGap;
      int totalGapsHeight = (targetRows - 1) * verticalGap;

      int totalWidth = size.width.round() -
          leftInsets -
          margins.right.round() -
          totalGapsWidth;
      int totalHeight = size.height.round() -
          topInsets -
          margins.bottom.round() -
          totalGapsHeight;

      int columnSize = (totalWidth / targetColumns).round();
      int rowSize = (totalHeight / targetRows).round();

      int widthCalcError = totalWidth - columnSize * targetColumns;
      int heightCalcError = totalHeight - rowSize * targetRows;
      int xMiddle = 0;
      if (widthCalcError > 0) {
        xMiddle = ((targetColumns / widthCalcError + 1) / 2).round();
      }
      int yMiddle = 0;
      if (heightCalcError > 0) {
        yMiddle = ((targetRows / heightCalcError + 1) / 2).round();
      }

      if (xPosition == null || xPosition.length != targetColumns + 1) {
        xPosition = new List<int>(targetColumns + 1);
      }
      xPosition[0] = leftInsets;
      int corrX = 0;
      for (int i = 0; i < targetColumns; i++) {
        xPosition[i + 1] = xPosition[i] + columnSize + horizontalGap;
        if (widthCalcError > 0 &&
            corrX * targetColumns / widthCalcError + xMiddle == i) {
          xPosition[i + 1]++;
          corrX++;
        }
      }

      if (yPosition == null || yPosition.length != targetRows + 1) {
        yPosition = new List<int>(targetRows + 1);
      }
      yPosition[0] = topInsets;
      int corrY = 0;
      for (int i = 0; i < targetRows; i++) {
        yPosition[i + 1] = yPosition[i] + rowSize + verticalGap;
        if (heightCalcError > 0 &&
            corrY * targetRows / heightCalcError + yMiddle == i) {
          yPosition[i + 1]++;
          corrY++;
        }
      }

      constraintMap?.forEach((component, constraints) {
        EdgeInsets insets = constraints.insets;

        double x = getPosition(
                xPosition, constraints.gridX, columnSize, horizontalGap) +
            insets.left;
        double y =
            getPosition(yPosition, constraints.gridY, rowSize, verticalGap) +
                insets.top;
        double width = getPosition(
                xPosition,
                constraints.gridX + constraints.gridWidth,
                columnSize,
                horizontalGap) -
            horizontalGap -
            x -
            insets.right;
        double height = getPosition(
                yPosition,
                constraints.gridY + constraints.gridHeight,
                rowSize,
                verticalGap) -
            verticalGap -
            y -
            insets.bottom;

        component.layout(
            BoxConstraints(
                minWidth: width,
                maxWidth: width,
                minHeight: height,
                maxHeight: height),
            parentUsesSize: true);

        final MultiChildLayoutParentData childParentData = component.parentData;
        childParentData.offset = Offset(x, y);
      });

      this.size = size;
    }
  }

  Size getPreferredSize(
      RenderBox renderBox, CoGridLayoutConstraints constraint) {
    if (!constraint.comp.componentModel.isPreferredSizeSet) {
      Size size = getChildLayoutPreferredSize(renderBox);
      if (size != null) {
        return size;
      } else {
        if (renderBox.hasSize)
          size = renderBox.size;
        else
          size = layoutRenderBox(renderBox, constraints);
        //renderBox.layout(constraints, parentUsesSize: true);

        if (size == null) {
          print("CoBorderLayout: RenderBox has no size after layout!");
        }

        if (size.width == double.infinity || size.height == double.infinity) {
          print(
              "CoBorderLayout: getPrefererredSize: Infinity height or width for BorderLayout!");
        }
        return size;
      }
    } else {
      return constraint.comp.componentModel.preferredSize;
    }
  }

  Size _preferredLayoutSize(ContainerComponentModel pParent) {
    double maxWidth = 0;
    double maxHeight = 0;

    int targetColumns = columns;
    int targetRows = rows;

    constraintMap?.forEach((component, constraints) {
      EdgeInsets insets = constraints.insets;

      Size pref = getPreferredSize(component, constraints);
      double width =
          (pref.width + constraints.gridWidth - 1) / constraints.gridWidth +
              insets.left +
              insets.right;
      if (width > maxWidth) {
        maxWidth = width;
      }
      double height =
          (pref.height + constraints.gridHeight - 1) / constraints.gridHeight +
              insets.top +
              insets.bottom;
      if (height > maxHeight) {
        maxHeight = height;
      }

      if (columns <= 0 &&
          constraints.gridX + constraints.gridWidth > targetColumns) {
        targetColumns = constraints.gridX + constraints.gridWidth;
      }
      if (rows <= 0 &&
          constraints.gridY + constraints.gridHeight > targetRows) {
        targetRows = constraints.gridY + constraints.gridHeight;
      }
    });

    return new Size(
        maxWidth * targetColumns +
            margins.left +
            margins.right +
            horizontalGap * (targetColumns - 1),
        maxHeight * targetRows +
            margins.top +
            margins.bottom +
            verticalGap * (targetRows - 1));

    //EdgeInsets parentInsets = pParent.insets;

    /*return new Size(maxWidth * targetColumns + parentInsets.left + parentInsets.right 
				  + margins.left + margins.right + horizontalGap * (targetColumns - 1),
				  maxHeight * targetRows + parentInsets.bottom + parentInsets.top 
				   + margins.top + margins.bottom + verticalGap * (targetRows - 1));
*/
  }

  Size _minimumLayoutSize(ContainerComponentModel parent) {
    return Size(0, 0);
  }

  Size _maximumLayoutSize(ContainerComponentModel pTarget) {
    return Size(double.infinity, double.infinity);
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
  bool hitTestChildren(HitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  /*
	 * Gets in any case an position inside the grid.
	 * @param pPositions the stored positions.
	 * @param pIndex the index
	 * @param pSize the size of column or row
	 * @param pGap the gap
	 * @return the position
	 */
  static int getPosition(
      List<int> pPositions, int pIndex, int pSize, int pGap) {
    if (pIndex < 0) {
      return pPositions[0] + pIndex * (pSize + pGap);
    } else if (pIndex >= pPositions.length) {
      return pPositions[pPositions.length - 1] +
          (pIndex - pPositions.length + 1) * (pSize + pGap);
    } else {
      return pPositions[pIndex];
    }
  }

  void addLayoutComponent(RenderBox pComp, Object pConstraints) {
    ArgumentError.checkNotNull(
        pConstraints, "The constraints must not be null.");

    if (pConstraints is CoGridLayoutConstraints) {
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
  void setConstraints(
      RenderBox pComponent, CoGridLayoutConstraints pConstraints) {
    ArgumentError.checkNotNull(pComponent, "The component must not be null.");
    ArgumentError.checkNotNull(
        pConstraints, "The constraints must not be null.");

    constraintMap.putIfAbsent(pComponent, () => pConstraints);
  }
}

class CoGridLayoutConstraintData
    extends ParentDataWidget<MultiChildLayoutParentData> {
  /// Marks a child with a layout identifier.
  ///
  /// Both the child and the id arguments must not be null.
  CoGridLayoutConstraintData({
    Key key,
    this.id,
    @required Widget child,
  })  : assert(child != null),
        super(key: key ?? ValueKey<Object>(id), child: child);

  /// An object representing the identity of this child.
  ///
  /// The [id] needs to be unique among the children that the
  /// [CustomMultiChildLayout] manages.
  final CoGridLayoutConstraints id;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is MultiChildLayoutParentData);
    final MultiChildLayoutParentData parentData = renderObject.parentData;
    if (parentData.id != id) {
      parentData.id = id;
      final AbstractNode targetParent = renderObject.parent;
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
