import 'package:flutter/widgets.dart';

import '../../component/component_widget.dart';

class CoGridLayoutConstraints {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // The position on the x-axis.
  int? _gridX;

  // The position on the y-axis.
  int? _gridY;

  // The width of the component in grids.
  int? _gridWidth;

  // The height of the component in grids.
  int? _gridHeight;

  // The specified insets of the component.
  EdgeInsets? _insets;

  ComponentWidget? comp;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /*
		 * Constructs a new CellConstraint.
		 */
  CoGridLayoutConstraints() {
    CoGridLayoutConstraints.fromGridPosition(0, 0);
  }

  /*
		 * Constructs a new CellConstraint with the given parameters.
		 * 
		 * @param pGridX the position on the x-axis
		 * @param pGridY the position on the y-axis
		 */
  CoGridLayoutConstraints.fromGridPosition(int pGridX, int pGridY) {
    CoGridLayoutConstraints.fromGridPositionAndSizeAndInsets(
        pGridX, pGridY, 1, 1, null);
  }

  /*
		 * Constructs a new CellConstraint with the given parameters.
		 * 
		 * @param pGridX the position on the x-axis
		 * @param pGridY the position on the y-axis
		 * @param pWidth the width of the component
		 * @param pHeight the height of the component
		 */
  CoGridLayoutConstraints.fromGridPositionAndSize(
      int pGridX, int pGridY, int pWidth, int pHeight) {
    CoGridLayoutConstraints.fromGridPositionAndSizeAndInsets(
        pGridX, pGridY, pWidth, pHeight, null);
  }

  /*
		 * Constructs a new CellConstraint with the given parameters.
		 * 
		 * @param pGridX the position on the x-axis
		 * @param pGridY the position on the y-axis
		 * @param pGridWidth the width of the component
		 * @param pGridHeight the height of the component
		 * @param pInsets the specified insets
		 */
  CoGridLayoutConstraints.fromGridPositionAndSizeAndInsets(int pGridX,
      int pGridY, int pGridWidth, int pGridHeight, EdgeInsets? pInsets) {
    gridX = pGridX;
    gridY = pGridY;
    gridWidth = pGridWidth;
    gridHeight = pGridHeight;
    insets = pInsets;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /*
		 * Returns the x-position on the grid.
		 *
		 * @return the x-position
		 */
  int? get gridX {
    return _gridX;
  }

  /*
		 * Sets the x-position on the GridLayout.
		 *
		 * @param pGridX the x-position to set
		 */
  set gridX(int? pGridX) {
    if (pGridX != null && pGridX < 0) {
      throw new RangeError("The grid x must be a positive number.");
    }

    _gridX = pGridX;
  }

  /*
		 * Returns the y-position on the GridLayout.
		 *
		 * @return the y-position
		 */
  int? get gridY {
    return _gridY;
  }

  /*
		 * Sets the y-position on the GridLayout.
		 *
		 * @param pGridY the x-position to set
		 */
  set gridY(int? pGridY) {
    if (pGridY != null && pGridY < 0) {
      throw new RangeError("The grid y must be a positive number.");
    }

    _gridY = pGridY;
  }

  /*
		 * Returns the width on the GridLayout.
		 *
		 * @return the width
		 */
  int? get gridWidth {
    return _gridWidth;
  }

  /*
		 * Sets the width on the GridLayout.
		 *
		 * @param pGridWidth the height to set
		 */
  set gridWidth(int? pGridWidth) {
    if (pGridWidth != null && pGridWidth <= 0) {
      throw new RangeError("The grid width must be a positive number.");
    }

    _gridWidth = pGridWidth;
  }

  /*
		 * Returns the height on the GridLayout.
		 *
		 * @return the height
		 */
  int? get gridHeight {
    return _gridHeight;
  }

  /*
		 * Sets the height on the GridLayout.
		 *
		 * @param pGridHeight the height to set
		 */
  set gridHeight(int? pGridHeight) {
    if (pGridHeight != null && pGridHeight <= 0) {
      throw new RangeError("The grid height must be a positive number.");
    }

    _gridHeight = pGridHeight;
  }

  /*
		 * Returns the insets on the GridLayout.
		 *
		 * @return the insets
		 */
  EdgeInsets? get insets {
    return _insets;
  }

  /*
		 * Sets the width on the GridLayout.
		 *
		 * @param pInsets the insets to set
		 */
  set insets(EdgeInsets? pInsets) {
    if (pInsets == null) {
      _insets = EdgeInsets.zero;
    } else {
      _insets = pInsets;
    }
  }
}
